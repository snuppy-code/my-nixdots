{
  description = "My first flake :3";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };
  outputs = inputs: {
    nixosConfigurations = {
      snuppynixos = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
