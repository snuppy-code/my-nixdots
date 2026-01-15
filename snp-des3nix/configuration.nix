# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
	imports = [
	];
        
	stylix.enable = true;
        stylix.autoEnable = false;
        stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
        stylix.image = ./../wallpapers/highres/wp3.png;
        # The generated color scheme can be viewed at /etc/stylix/palette.html on NixOS, or at ~/.config/stylix/palette.html on Home Manager.
        #stylix.polarity = "dark";
        stylix.fonts = {
                #serif = {
                #  package = pkgs.dejavu_fonts;
                #  name = "DejaVu Serif";
                #};
                #sansSerif = {
                #  package = pkgs.dejavu_fonts;
                #  name = "DejaVu Sans";
                #};
                monospace = {
                        package = pkgs.nerd-fonts._0xproto;
                        name = "0xProto Nerd Font";
                };
                #emoji = {
                #  package = pkgs.noto-fonts-color-emoji;
                #  name = "Noto Color Emoji";
                #};
        };
        fonts.packages = with pkgs; [
                nerd-fonts._0xproto
                        nerd-fonts.jetbrains-mono
                        nerd-fonts.adwaita-mono
                        nerd-fonts.agave
                        nerd-fonts.arimo
                        nerd-fonts.aurulent-sans-mono
                        nerd-fonts.bigblue-terminal
                        nerd-fonts.caskaydia-mono
                        nerd-fonts.commit-mono
                        nerd-fonts.departure-mono
                        nerd-fonts.dejavu-sans-mono
                        nerd-fonts.go-mono
                        nerd-fonts.inconsolata
                        nerd-fonts.iosevka-term
                        nerd-fonts.iosevka-term-slab
                        nerd-fonts.overpass
                        nerd-fonts.sauce-code-pro
                        nerd-fonts.tinos
        ];
        
        boot.kernelPackages = pkgs.linuxPackages; # linuxPackages = LTS !
        networking.networkmanager.wifi.powersave = false; # I would imagine if anything this is actively detrimental but first time with 19 hours uptime this is true
        hardware.cpu.intel.updateMicrocode = true;
        powerManagement.enable = false;
        systemd.targets.sleep.enable = false;
        systemd.targets.suspend.enable = false;
        systemd.targets.hibernate.enable = false;
        systemd.targets.hybrid-sleep.enable = false;
        systemd.sleep.extraConfig = ''
                AllowSuspend=no
                AllowHibernation=no
                AllowHybridSleep=no
                AllowSuspendThenHibernate=no
                '';
        services.logind.settings.Login.HandleLidSwitch = "ignore";
        services.logind.settings.Login.HandleLidSwitchDocked = "ignore";
        services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
        boot.kernelParams = [
                "intel_idle.max_cstate=1"
                "processor.max_cstate=1"
        ];
        
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

	networking.hostName = "snp-des3nix";
	networking.networkmanager.enable = true;
        services.tailscale.enable = true;

	time.timeZone = "Europe/Oslo";

	i18n.defaultLocale = "en_US.UTF-8";
	i18n.extraLocaleSettings = {
		LC_ADDRESS = "nb_NO.UTF-8";
		LC_IDENTIFICATION = "nb_NO.UTF-8";
		LC_MEASUREMENT = "nb_NO.UTF-8";
		LC_MONETARY = "nb_NO.UTF-8";
		LC_NAME = "nb_NO.UTF-8";
		LC_NUMERIC = "nb_NO.UTF-8";
		LC_PAPER = "nb_NO.UTF-8";
		LC_TELEPHONE = "nb_NO.UTF-8";
		LC_TIME = "nb_NO.UTF-8";
	};

	users.users.mend = {
		isNormalUser = true;
		description = "mend";
		extraGroups = [ "networkmanager" "wheel" ];
		initialPassword = "changeme";
                openssh.authorizedKeys.keys = [
                        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILywcKsOrkjA6Zz0Nzv4zSkVSc67Yp8e1FZZql7AETTLAAAABHNzaDo= snuppy.code@pm.me"
                ];
	};

	nixpkgs.config.allowUnfree = true;
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	environment.systemPackages = with pkgs; [
	];

	services.openssh = {
		enable = true;
		settings = {
			PermitRootLogin = "no";
		};
		extraConfig = ''
			Match user git
			AllowTcpForwarding no
			AllowAgentForwarding no
			PasswordAuthentication no
			PermitTTY no
			X11Forwarding no
		'';
	};
	programs.ssh = {
		extraConfig = ''
			Host snp-des2nix
				Hostname 192.168.30.174
				Port 22
                                IdentityFile ~/.ssh/mend-snp-des3nix
                                IdentitiesOnly yes
		'';
	};

	# git on the server ! - https://nixos.wiki/wiki/Git
	#users.users.git = {
	#	isSystemUser = true;
	#	group = "git";
	#	home = "/var/lib/git-server";
	#	createHome = true;
	#	shell = "${pkgs.git}/bin/git-shell";
	#	openssh.authorizedKeys.keys = [
	#		"sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILywcKsOrkjA6Zz0Nzv4zSkVSc67Yp8e1FZZql7AETTLAAAABHNzaDo= snuppy.code@pm.me"
	#		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILDkgmUlpM3cGE0MDHU0QyCtspkpImLjQVpkU7ihv5P9 mend@snp-des2nix"
	#	];
	#};
	#users.groups.git = {};

	programs.git = {
		enable = true;
		config = {
			init.defaultBranch = "main";
                        user.name = "snuppy";
                        user.email = "snuppy.code@pm.me";
		};
	};

	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "25.11"; # Did you read the comment?

}
