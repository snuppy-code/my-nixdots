{
  	description = "My first flake :3";

  	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		
		home-manager.url = "github:nix-community/home-manager";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
		
		stylix.url = "github:nix-community/stylix";
		stylix.inputs.nixpkgs.follows = "nixpkgs";
		
		spicetify-nix.url = "github:Gerg-L/spicetify-nix";
		spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
	};
  
	outputs = { self, nixpkgs, home-manager, stylix, spicetify-nix }@inputs: {
		nixosConfigurations.snp-lap1nix = nixpkgs.lib.nixosSystem {
		
		specialArgs = { inherit inputs; };
        		modules = [
				stylix.nixosModules.stylix
				./snp-lap1nix/configuration.nix
				home-manager.nixosModules.home-manager {
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;
				
					home-manager.users.snuppy = (import ./snp-lap1nix/snuppy-home.nix);
					home-manager.extraSpecialArgs = { inherit inputs; };
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
