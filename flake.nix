{
  
  description = "My first flake :3";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };
  
  # Here you will commonly see `inputs` as parameter, and smth like `{ self, nixpkgs }`. Remember that these are only parameters, not referencing stuff in this flake there.
  # When nix calls this lambda, it gives it an attribute set with
  outputs = inputs: {
    nixosConfigurations = {
      # can have multiple. by default `sudo nixos-rebuild switch --flake .` looks for the configuration matching my hostname, but I can specify another configuration with a # after the .
      snuppynixos = inputs.nixpkgs.lib.nixosSystem {
        modules = [
	  # can potentially comment the line below?
          #{ nix.settings.experimental-features = ["nix-command" "flakes"]; }
          ./configuration.nix
        ];
      };
    };
  };
  
}
