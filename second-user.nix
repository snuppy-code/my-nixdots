{ lib, config, pkgs, ... }: {
	options = {
		second-user.enable = lib.mkEnableOption "enable second user";
		second-user.userName = lib.mkOption {
			default = "myseconduser";
			description = "give string username I think";
		};
	};

	config = lib.mkIf config.second-user.enable {
		users.users.${config.second-user.userName} = {
			isNormalUser = true;
			extraGroups = [ "networkmanager" "wheel" ];
			description = "the second user";
		};
	};
}
