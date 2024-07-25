# Determinate Nix

Install and manage Determinate Nix.

## NixOS

```nix
{
  inputs.nix.url = "https://flakehub.com/f/DeterminateSystems/nix/2.0";
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2405.*";

  outputs = { nix, nixpkgs, ... }: {
    nixosConfigurations.my-workstation = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          imports = [
            nix.nixosModules.default
          ];
          # the rest of your configuration
        })
      ];
    };
  };
}
```

## nix-darwin

```nix
{
  inputs.nix.url = "https://flakehub.com/f/DeterminateSystems/nix/2.0";
  inputs.nix-darwin.url = "github:LnL7/nix-darwin";

  outputs = { nix, nix-darwin, ... }: {
    darwinConfigurations.my-workstation-aarch64-darwin = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ({ pkgs, ... }: {
          imports = [
            nix.darwinModules.default
          ];
          # the rest of your configuration
        })
      ];
    };
  };
}
```

## Home Manager

```nix
{
  inputs.nix.url = "https://flakehub.com/f/DeterminateSystems/nix/2.0";
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2405.*";
  inputs.home-manager.url = "https://flakehub.com/f/nix-community/home-manager/0.2405.*";

  outputs = { nix, nixpkgs, home-manager, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      homeConfigurations.my-workstation = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          nix.homeModules.default
        ];
      };
    }
}
```
