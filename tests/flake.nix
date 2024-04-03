{
  inputs = {
    nix.url = "path:../";
    nixpkgs.follows = "nix/nixpkgs";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      # Switch to /release-23.11 and drop `home.enableNixpkgsReleaseCheck = false;` when https://github.com/nix-community/home-manager/pull/5161 is merged
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix, home-manager, nix-darwin, ... }:
    let
      checkNixConfSetting = { system, binDir, configDir, build, expect }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.runCommand "${build.name}-check"
          {
            buildInputs = [ pkgs.jq pkgs.dyff ];
            expect = builtins.toJSON expect;
            passAsFile = [ "expect" ];
          } ''
          set -o pipefail

          NIX_CONF_DIR=${build}/${configDir} ${build}/${binDir}/nix config show --json \
            | jq \
              --sort-keys \
              --slurpfile expect "$expectPath" \
              '[to_entries[] | { key: .key, value: .value.value } | select(.key | in($expect[0]))] | from_entries' > rendered.json

          echo "Rendered nix.conf:"
          cat "${build}/${configDir}/nix.conf"

          echo "All Nix settings:"
          NIX_CONF_DIR=${build}/${configDir} ${build}/${binDir}/nix config show --json \
            | jq \
              --sort-keys \
              --slurpfile expect "$expectPath" \
              '[to_entries[] | { key: .key, value: .value.value }] | from_entries'

          dyff between --set-exit-code "$expectPath" ./rendered.json
          touch "$out"
        '';
    in
    {
      checks.x86_64-linux.nixos = (nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nix.nixosModules.default
          {
            fileSystems."/" = {
              device = "/dev/bogus";
              fsType = "ext4";
            };
            boot.loader.grub.devices = [ "/dev/bogus" ];
          }
        ];
      }).config.system.build.toplevel;

      checks.x86_64-linux.home-manager = (home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        modules = [
          nix.homeManagerModules.default
          {
            home.stateVersion = "23.11";
            home.username = "example";
            home.homeDirectory = "/no-such/directory";
            home.enableNixpkgsReleaseCheck = false;
          }
        ];
      }).activation-script;

      checks.x86_64-darwin.nix-darwin = (nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin";

        modules = [
          ({ pkgs, ... }: {
            imports = [
              nix.darwinModules.default
            ];
          })
        ];
      }).system;


      checks.x86_64-darwin.nix-darwin-with-sandbox = checkNixConfSetting {
        system = "x86_64-darwin";
        binDir = "sw/bin";
        configDir = "etc/nix";
        expect = {
          sandbox = true;
          extra-sandbox-paths = [ "/private/etc/ssl/openssl.cnf" ];
        };

        build = (nix-darwin.lib.darwinSystem {
          system = "x86_64-darwin";

          modules = [
            ({ pkgs, ... }: {
              imports = [
                nix.darwinModules.default
              ];

              nix.settings.sandbox = true;
            })
          ];
        }).system;
      };
    };
}
