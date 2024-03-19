{
  inputs = {
    nix.url = "path:../";
    nixpkgs.follows = "nix/nixpkgs";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix, home-manager, nix-darwin, ... }: {
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
    }).nixos.config.system.build.toplevel;

    checks.aarch64-darwin.home-manager = (home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;

      modules = [
        nix.homeManagerModules.default
        {
          home.stateVersion = "23.11";
          home.username = "example";
          home.homeDirectory = "/no-such/directory";
        }
      ];
    });

    checks.aarch64-darwin.nix-darwin = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";

      modules = [
        ({ pkgs, ... }: {
          imports = [
            nix.darwinModules.default
          ];
        })
      ];
    };
  };
}
