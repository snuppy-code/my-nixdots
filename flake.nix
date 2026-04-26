{
  description = ":3c";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nvf.url = "github:notashelf/nvf";
    nvf.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix/release-25.11";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    sops-nix,
    nvf,
    stylix,
    spicetify-nix,
  } @ inputs: {
    nixosConfigurations.snp-des1nix = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };
      modules = [
        ./all-common.nix
        ./cli-common.nix
        ./personal-common.nix
        ./personal-style.nix
        ./snp-des1nix/configuration.nix
        ./snp-des1nix/hardware-myextra.nix
        ./snp-des1nix/hardware-configuration.nix
        home-manager.nixosModules.home-manager
        { home-manager.users.snuppy = { imports = [
            ./snp-des1nix/snuppy-home.nix
            ./snuppy-home-common.nix
          ];}; }
        sops-nix.nixosModules.sops
        nvf.nixosModules.default
        stylix.nixosModules.stylix
        spicetify-nix.nixosModules.spicetify
      ];
    };
    nixosConfigurations.snp-lap1nix = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };
      modules = [
        ./all-common.nix
        ./cli-common.nix
        ./personal-common.nix
        ./personal-style.nix
        ./snp-lap1nix/configuration.nix
        ./snp-lap1nix/hardware-configuration.nix
        home-manager.nixosModules.home-manager
        { home-manager.users.snuppy = { imports = [
            ./snp-lap1nix/snuppy-home.nix
            ./snuppy-home-common.nix
          ];}; }
        sops-nix.nixosModules.sops
        nvf.nixosModules.default
        stylix.nixosModules.stylix
        spicetify-nix.nixosModules.spicetify
      ];
    };
    nixosConfigurations.snp-des2nix = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./all-common.nix
        ./cli-common.nix
        ./snp-des2nix/configuration.nix
        ./snp-des2nix/hardware-configuration.nix
        sops-nix.nixosModules.sops
        nvf.nixosModules.default
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        {
          mycli.username = "mend";
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.mend = import ./mend-home.nix;
          home-manager.extraSpecialArgs = {inherit inputs;};
        }
      ];
    };

    # nixosConfigurations.snp-nuc1nix = nixpkgs.lib.nixosSystem {
    #   specialArgs = {inherit inputs;};
    #   modules = [
    #     ./snp-nuc1nix/configuration.nix
    #     ./cli-common.nix
    #     ./snp-nuc1nix/hardware-configuration.nix
    #     home-manager.nixosModules.home-manager
    #     nvf.nixosModules.default
    #     stylix.nixosModules.stylix
    #     {
    #       mycli.username = "mend";
    #       home-manager.useGlobalPkgs = true;
    #       home-manager.useUserPackages = true;
    #       home-manager.users.mend = import ./mend-home.nix;
    #       home-manager.extraSpecialArgs = {inherit inputs;};
    #     }
    #   ];
    # };
    # nixosConfigurations.snp-des3nix = nixpkgs.lib.nixosSystem {
    #   specialArgs = {inherit inputs;};
    #   modules = [
    #     ./snp-des3nix/configuration.nix
    #     ./cli-common.nix
    #     ./sops-common.nix
    #     ./snp-des3nix/hardware-configuration.nix
    #     sops-nix.nixosModules.sops
    #     nvf.nixosModules.default
    #     stylix.nixosModules.stylix
    #     home-manager.nixosModules.home-manager
    #     {
    #       mycli.username = "mend";
    #       home-manager.useGlobalPkgs = true;
    #       home-manager.useUserPackages = true;
    #       home-manager.users.mend = import ./mend-home.nix;
    #       home-manager.extraSpecialArgs = {inherit inputs;};
    #     }
    #   ];
    # };
  };
}
