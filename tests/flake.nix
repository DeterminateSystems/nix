{
    inputs = {
        nix.url = "path:../";
        nixpkgs.follows = "nix/nixpkgs";
    };

    outputs = { nixpkgs, nix, ... }: {
      checks.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          #nix.nixosModules.default
        ];
      };
    };
}