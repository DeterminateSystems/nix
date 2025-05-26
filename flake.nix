{
  description = "Determinate Nix";
  inputs = {
    nix.url = "https://flakehub.com/f/NixOS/nix/=2.29.0";
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

      migrationNotice = moduleType: {
        assertions = [
          {
            assertion = false;
            message = ''
              🏳️ Deprecated flake module: DeterminateSystems/nix#${moduleType}.default 🏳️ -

              The DeterminateSystems/nix repository's modules are deprecated because it is unclear what it is for.
              The README says it gives you Determinate Nix, but it actually installs Nix from upstream.
            '';
          }
          {
            assertion = moduleType != "darwinModules";
            message = ''
              Determinate Nix is fully compatible with nix-darwin.
            
              To fix this issue, please:
              
              1. install Determinate Nix with the macOS package from https://docs.determinate.systems/
              2. set `nix.enable = false` in your nix-darwin configuration
              3. delete the `DeterminateSystems/nix` reference from your flake inputs,
              4. delete `nix.${moduleType}.default` from your nix-darwin modules list
              5. rebuild your nix-darwin configuration
            '';
          }
          {
            assertion = moduleType != "nixosModules";
            message = ''
              Determinate Nix is fully compatible with NixOS.

              To fix this issue, please:
                
                1. replace the `DeterminateSystems/nix` flake input with:

                    inputs.determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

                2. replace the `nix.${moduleType}.default` module in your NixOS modules list with:
              
                    determinate.${moduleType}.default

                3. rebuild your NixOS configuration, passing a couple extra options so you don't have to compile Determinate Nix yourself:

                    sudo nixos-rebuild \
                      switch \
                      --option extra-substituters https://install.determinate.systems \
                      --option extra-trusted-public-keys cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM= \
                      --flake ...

              For more details: https://docs.determinate.systems/guides/advanced-installation/#nixos
            '';
          }
          {
            assertion = moduleType != "homeModules" && moduleType != "homeManagerModules";
            message = ''
              Determinate Nix doesn't offer a home-manager module, because it must be configured at the host level.

              Install or configure Determinate Nix on your system with our getting started documentation:
              https://docs.determinate.systems/
            '';
          }
          {
            assertion = false;
            message = ''
              We're available to help!
                * Reach out on Discord: https://determinate.systems/discord
                * Contact support: support@determinate.systems
            '';
          }
        ];
      };
    in
    {
      closures = forAllSystems ({ system, ... }: nix.packages."${system}".default);
      tarballs_indirect = forAllSystems ({ system, ... }: nix.packages."${system}".binaryTarball);
      tarballs_direct = forAllSystems ({ system, ... }: "${nix.packages."${system}".binaryTarball}/nix-${nix.packages."${system}".default.version}-${system}.tar.xz");

      checks = forAllSystems ({ system, ... }: {
        closure = nix.packages."${system}".default;
        tarball = nix.packages."${system}".binaryTarball;
      });

      packages = forAllSystems ({ system, pkgs, ... }: {
        default = nix.packages."${system}".default;

        tarballs_json = pkgs.runCommand "tarballs.json"
          {
            buildInputs = [ pkgs.jq ];
            passAsFile = [ "json" ];
            json = builtins.toJSON (self.tarballs_direct);
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

      darwinModules.default = migrationNotice "darwinModules";
      nixosModules.default =  migrationNotice "nixosModules";
      homeModules.default = migrationNotice "homeModules";
      homeManagerModules.default = migrationNotice "homeManagerModules";
    };
}
