{
  
  description = "My first flake :3";
  
  # a reference: https://github.com/gpskwlkr/nixos-hyprland-flake/blob/main/flake.nix
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  
  # Here you will commonly see `inputs` as parameter, and smth like `{ self, nixpkgs }`. Remember that these are only parameters, not referencing stuff in this flake there.
  # When nix calls this lambda, it gives it an attribute set with
  outputs = { self, nixpkgs, home-manager }: {
    nixosConfigurations = {
      # can have multiple. by default `sudo nixos-rebuild switch --flake .` looks for the configuration matching my hostname, but I can specify another configuration with a # after the .
      snp-lap1nix = nixpkgs.lib.nixosSystem {
        modules = [
	  # can potentially comment the line below?
          #{ nix.settings.experimental-features = ["nix-command" "flakes"]; }
          ./configuration.nix
	  #home-manager.nixosModules.home-manager
        ];
      };
      #snp-des1nix = nixpkgs.lib.nixosSystem {
      #  modules = [
#	  ./configuration-snp-des1nix.nix
#	];
#      };
    };
  };
  
}
