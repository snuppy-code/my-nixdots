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
	outputs = { self, nixpkgs, home-manager }@inputs: {
	# can have multiple. by default `sudo nixos-rebuild switch --flake .` looks for the configuration matching my hostname, but I can specify another configuration with a # after the .
		nixosConfigurations.snp-lap1nix = nixpkgs.lib.nixosSystem {
			specialArgs = { inherit inputs; };
        		modules = [
				./snp-lap1nix/configuration.nix
				home-manager.nixosModules.home-manager {
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;

					home-manager.users.snuppy = (import ./snp-lap1nix/snuppy-home.nix);
					# home-manager.extraSpecialArgs = { some stuf }
				}
        		];
		};
		nixosConfigurations.snp-nuc1nix = nixpkgs.lib.nixosSystem {
			specialArgs = { inherit inputs; };
			modules = [
				./snp-nuc1nix/configuration.nix
				home-manager.nixosModules.home-manager {
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;

					home-manager.users.mend = (import ./snp-nuc1nix/mend-home.nix);
				}
			];
		};
	};
}
