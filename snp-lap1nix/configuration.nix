# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
        imports = [
        ];

        sops.secrets.snuppy-password.neededForUsers = true;
        users.users.snuppy = {
                extraGroups = [ "networkmanager" "wheel" ];
                description = "snuppy";
                isNormalUser = true;
                hashedPasswordFile = config.sops.secrets.snuppy-password.path;
                openssh.authorizedKeys.keys = [
			"sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILywcKsOrkjA6Zz0Nzv4zSkVSc67Yp8e1FZZql7AETTLAAAABHNzaDo= snuppy.code@pm.me"
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILDkgmUlpM3cGE0MDHU0QyCtspkpImLjQVpkU7ihv5P9 mend@snp-des2nix"
		];
        };

        stylix.enable = true;
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
        stylix.autoEnable = false;

        # https://nix-community.github.io/stylix/options/modules/firefox.html
        # about:profiles
        programs.firefox.enable = true;

        programs.spicetify = {
                enable = true;
        #theme = pkgs.lib.mkForce inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system}.themes.catppuccin;
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

        services.logind.settings.Login = { # one of "ignore", "poweroff", "reboot", "halt", "kexec", "suspend", "hibernate", "hybrid-sleep", "suspend-then-hibernate", "lock"
                HandleLidSwitch = "hybrid-sleep"; # like sleep (suspend) but also prepares hibernation, so if battery runs out I can still resume as if from hibernation
                        HandleLidSwitchExternalPower = "lock";
                HandleLidSwitchDocked = "ignore";
        };
        powerManagement.enable = true; #https://nixos.wiki/wiki/Laptop
                services.thermald.enable = true;
        # https://github.com/NixOS/nixos-hardware/blob/master/lenovo/yoga/7/14IAH7/shared.nix
        boot.kernelParams = [
                "pcie_aspm.policy=powersupersave"
                        "mem_sleep_default=deep"
        ];
        services.fstrim.enable = true;

        services.power-profiles-daemon.enable = false; # KDE and Gnome both enable this one, so I disable it to instead use tlp
                services.tlp.enable = true;
        services.tlp.settings = { #mostly settings making it throttle on battery and not on AC
                CPU_SCALING_GOVERNOR_ON_AC = "performance"; 
                CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

                CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
                CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

                CPU_MIN_PERF_ON_AC = 0;
                CPU_MAX_PERF_ON_AC = 100;
                CPU_MIN_PERF_ON_BAT = 0;
                CPU_MAX_PERF_ON_BAT = 20;

        # maybe slightly help battery life
                START_CHARGE_THRESH_BAT0 = 40;
                STOP_CHARGE_THRESH_BAT0 = 80;
        };

        boot.kernelPackages = pkgs.linuxPackages_latest; # latest kernel.
        #boot.initrd.kernelModules ;

        # Resolves return from sleep on Wi-Fi 7 BE200 (Gale Peak 2). This is from gemini :/ because I wasn't able to solve this on my own and this solves my issue.
                services.udev.extraRules = ''ACTION=="add|bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x272b", ATTR{d3cold_allowed}="0"'';

        # Gemini :/ says this makes nixos continue to get latest closed source firmware, which can help my sleep issue above
        # https://github.com/NixOS/nixos-hardware/blob/master/lenovo/yoga/7/slim/gen8/default.nix
        hardware.enableRedistributableFirmware = true;

        # https://wiki.nixos.org/wiki/Accelerated_Video_Playback
        # https://nixos.wiki/wiki/Intel_Graphics
        # https://wiki.nixos.org/wiki/Intel_Graphics
        hardware.graphics = {
                enable = true;
                extraPackages = with pkgs; [
                        intel-compute-runtime # for openCL, optional
                                intel-media-driver
                                vpl-gpu-rt
                ];
        };
        environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; #unsure if this is right?

        services.tailscale.enable = true;

        environment.systemPackages = with pkgs; [
                libfido2
        ];

        programs.ssh = {
                #snp-des2nix 192.168.30.174
                #snp-des3nix 192.168.30.144
                extraConfig = "
                        Host snp-nuc1nix
                        Hostname 192.168.30.65
                        Port 22
                        User mend

                        Host snp-des2nix
                        Hostname snp-des2nix.tailf46592.ts.net
                        Port 22
                        User mend

                        Host snp-des3nix
                        Hostname snp-des3nix.tailf46592.ts.net
                        Port 22
                        User mend
                ";
        };

        programs.steam = {
                enable = true;
                remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
                dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
                localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
        };

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        # Something something yubikey
        services.pcscd.enable = true;
        # yubikey sudo: https://nixos.wiki/wiki/Yubikey
        security.pam.services = {
                login.u2fAuth = true;
                sudo.u2fAuth = true;
        };

        networking.hostName = "snp-lap1nix";
        networking.networkmanager.enable = true; 
        hardware.bluetooth.enable = true;

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

# Enable the KDE Plasma Desktop Environment.
        services.displayManager.sddm.enable = true;
        services.desktopManager.plasma6.enable = true;

        # Enable CUPS to print documents.
        # services.printing.enable = true;

        # Enable sound with pipewire.
        services.pulseaudio.enable = false;
        security.rtkit.enable = true;
        services.pipewire = {
                enable = true;
                alsa.enable = true;
                alsa.support32Bit = true;
                pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;
        };


        # Allow unfree packages
        nixpkgs.config.allowUnfree = true;
        nix.settings.experimental-features = [ "nix-command" "flakes" ];

        # Some programs need SUID wrappers, can be configured further or are
        # started in user sessions.
        # programs.mtr.enable = true;
        # programs.gnupg.agent = {
        #   enable = true;
        #   enableSSHSupport = true;
        # };

        # List services that you want to enable:

        # Enable the OpenSSH daemon.
        services.openssh.enable = true;

        services.udev.packages = [ pkgs.yubikey-personalization ];

        #programs.ssh.startAgent = true;

        # Open ports in the firewall.
        # networking.firewall.allowedTCPPorts = [ ... ];
        # networking.firewall.allowedUDPPorts = [ ... ];
        # Or disable the firewall altogether.
        # networking.firewall.enable = false;
        #networking.firewall = {
        #        trustedInterfaces = [ "tailscale0" ];
        #        allowedUDPPorts = [ config.services.tailscale.port ];
        #        allowedTCPPorts = [ 22 ];
        #};

        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It‘s perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        system.stateVersion = "25.11"; # Did you read the comment?

}
