{ lib, config, pkgs, ... }: {
	users.users."axie" = {
		isNormalUser = true;
		extraGroups = [ "networkmanager" "wheel" ];
		description = "axie";
	};
}
