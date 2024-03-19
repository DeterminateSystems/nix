# Determinate Nix

Install and manage Determinate Nix.

## NixOS

```nix
{
  inputs.nix.url = "https://flakehub.com/f/DeterminateSystems/nix/2.0";

  outputs = { ... }: @ inputs {
    nixosConfigurations.default = nix-darwin.lib.darwinSystem {
      modules = [
        ({ pkgs, ... }: {
          imports = [
            inputs.nix.nixosModules.default
          ];
          /* ... rest of your configuration */
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

  outputs = { ... }: @ inputs {
    darwinConfigurations.aarch64-linux.default = nix-darwin.lib.darwinSystem {
      modules = [
        ({ pkgs, ... }: {
          imports = [
            inputs.nix.darwinModules.default
          ];
          /* ... rest of your configuration */
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

  outputs = { nixpkgs, home-manager, ... } @ inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations.jdoe = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          inputs.nix.homeManagerModules.default
        ];
      };
    }
}

```
