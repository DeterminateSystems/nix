# Determinate Nix

Install and manage Determinate Nix.

## NixOS

```nix
{
  inputs.nix.url = "https://flakehub.com/f/DeterminateSystems/nix/2.0";

  outputs = { nix, nix-darwin, ... }: {
    nixosConfigurations.default = nix-darwin.lib.darwinSystem {
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

  outputs = { nix, nix-darwin, ... }: {
    darwinConfigurations.aarch64-linux.default = nix-darwin.lib.darwinSystem {
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

  outputs = { nix, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations.jdoe = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          nix.homeManagerModules.default
        ];
      };
    }
}
```
