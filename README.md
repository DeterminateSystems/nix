# ‼️🚨 You probably want [DeterminateSystems/determinate][determinate]!

This repository used to provide NixOS, nix-darwin, and Home Manager modules for installing "[Determinate Nix][det-nix]."
However, it has always actually shipped Nix from upstream.
Instead of making it silently switch users over to a different Nix, we've replaced the modules with assertions to help people move.

## Migrating

### Migrating for nix-darwin users

Determinate Nix is fully compatible with nix-darwin.

To fix this issue:

1. Install Determinate Nix with the macOS package from https://docs.determinate.systems/
2. Set `nix.enable = false` in your nix-darwin configuration
3. Delete the `DeterminateSystems/nix` reference from your flake inputs,
4. Delete `nix.darwinModules.default` from your nix-darwin modules list
5. Rebuild your nix-darwin configuration

### Migrating for NixOS users

Determinate Nix is fully compatible with NixOS.

To fix this issue, please:

1. Replace the `DeterminateSystems/nix` flake input with:

  ```nix
  inputs.determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  ```

2. Replace the `nix.nixosModules.default` module in your NixOS modules list with:

  ```nix
  determinate.nixosModules.default
  ```

1. Rebuild your NixOS configuration, passing some extra options so you don't have to compile Determinate Nix yourself:

  ```shell
  sudo nixos-rebuild \
    switch \
    --option extra-substituters https://install.determinate.systems \
    --option extra-trusted-public-keys cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM= \
    --flake ...
  ```

For more details, see our [installation guide][nixos-guide].

### Migrating for home-manager users

Determinate Nix doesn't offer a home-manager module, because it must be configured at the host level.

Install or configure Determinate Nix on your system with our [getting started documentation][getting-started].

## Further help

We're available to help!

- Reach out on [Discord]
- Contact support at [support@determinate.systems][support]

## Does this repo do _anything?_

Yes.
This repository is used by [nix-installer] to get a recent working version of Nix from [upstream].

[det-nix]: https://docs.determinate.systems/determinate-nix
[determinate]: https://github.com/DeterminateSystems/determinate
[discord]: https://determinate.systems/discord
[getting-started]: https://docs.determinate.systems
[nix-installer]: https://github.com/DeterminateSystems/nix-installer
[nixos-guide]: https://docs.determinate.systems/guides/advanced-installation/#nixos
[support]: mailto:support@determinate.systems
[upstream]: https://github.com/NixOS/nix