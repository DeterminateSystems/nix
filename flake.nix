{
  description = "Determinate Nix";
  inputs = {
    nix.url = "https://flakehub.com/f/NixOS/nix/=2.20.5";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*";
  };

  outputs = { self, nix, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      targetedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"

        "i686-linux" # Not supported by Determinate Nix Installer
      ];

      forSystems = s: f: lib.genAttrs s (system: f rec {
        inherit system;
        pkgs = nixpkgs.legacyPackages.${system};
      });

      forAllSystems = forSystems targetedSystems;
    in
    {
      closures = forAllSystems ({ system, ... }: nix.packages."${system}".default);
      tarballs = forAllSystems ({ system, ... }: nix.checks."${system}".binaryTarball);

      checks = forAllSystems ({ system, ... }: {
        closure = nix.packages."${system}".default;
        tarball = nix.checks."${system}".binaryTarball;
      });

      packages = forAllSystems ({ system, pkgs, ... }: {
        default = nix.packages."${system}".default;

        tarballs_json = pkgs.runCommand "tarballs.json"
          {
            buildInputs = [ pkgs.jq ];
            passAsFile = [ "json" ];
            json = builtins.toJSON (self.tarballs);
          } ''
          cat "$jsonPath" | jq . > $out
        '';

        closures_json = pkgs.runCommand "versions.json"
          {
            buildInputs = [ pkgs.jq ];
            passAsFile = [ "json" ];
            json = builtins.toJSON (self.closures);
          } ''
          cat "$jsonPath" | jq . > $out
        '';

        closures_nix = pkgs.runCommand "versions.nix"
          {
            buildInputs = [ pkgs.jq ];
            passAsFile = [ "template" ];
            jsonPath = self.packages.${system}.closures_json;
            template = ''
              # Generated by https://github.com/DeterminateSystems/nix-upgrade based on the
              # flake at https://flakehub.com/flake/NixOS/nix, which is a mirror of the
              # upstream NixOS/nix project.
              builtins.fromJSON('''@closures@''')
            '';
          } ''
          export closures=$(cat "$jsonPath");
          substituteAll "$templatePath" "$out"
        '';
      });

      darwinModules.default = { lib, config, pkgs, ... }: {
        nix = {
          package = self.packages.${pkgs.stdenv.system}.default;

          registry.nixpkgs = {
            exact = true;
            from = {
              type = "nixpkgs";
              url = "indirect";
            };
            to = {
              type = "tarball";
              url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1.0.tar.gz";
            };
          };

          settings = {
            bash-prompt-prefix = "(nix:$name)\\040";
            experimental-features = [ "nix-command" "flakes" "repl-flake" ];
            extra-nix-path = [ "nixpkgs=flake:nixpkgs" ];
            upgrade-nix-store-path-url = "https://install.determinate.systems/nix-upgrade/stable/universal";
          };
        };

        services.nix-daemon.enable = true;
      };

      nixosModules.default = { lib, config, pkgs, ... }: {
        nix = {
          package = self.packages.${pkgs.stdenv.system}.default;

          registry.nixpkgs = {
            exact = true;
            from = {
              type = "nixpkgs";
              url = "indirect";
            };
            to = {
              type = "tarball";
              url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1.0.tar.gz";
            };
          };

          settings = {
            bash-prompt-prefix = "(nix:$name)\\040";
            experimental-features = [ "nix-command" "flakes" "repl-flake" ];
            extra-nix-path = [ "nixpkgs=flake:nixpkgs" ];
            upgrade-nix-store-path-url = "https://install.determinate.systems/nix-upgrade/stable/universal";
          };
        };
      };

      homeManagerModules.default = { lib, config, pkgs, ... }: {
        nix = {
          package = self.packages.${pkgs.stdenv.system}.default;

          registry.nixpkgs = {
            exact = true;
            from = {
              type = "nixpkgs";
              url = "indirect";
            };
            to = {
              type = "tarball";
              url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1.0.tar.gz";
            };
          };

          settings = {
            bash-prompt-prefix = "(nix:$name)\\040";
            experimental-features = [ "nix-command" "flakes" "repl-flake" ];
            extra-nix-path = [ "nixpkgs=flake:nixpkgs" ];
            upgrade-nix-store-path-url = "https://install.determinate.systems/nix-upgrade/stable/universal";
          };
        };
      };
    };
}
