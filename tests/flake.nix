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
    }).config.system.build.toplevel;

    checks.x86_64-linux.home-manager = (home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      modules = [
        nix.homeManagerModules.default
        {
          home.stateVersion = "23.11";
          home.username = "example";
          home.homeDirectory = "/no-such/directory";
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
  };
}
