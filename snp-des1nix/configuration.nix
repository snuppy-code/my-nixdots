# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
        imports = [
        ];

        services.smartd.enable = true; # SMART Daemon

        boot.kernelModules = [ "kvm-amd" ];
        virtualisation.libvirtd = {
                enable = true;
                qemu = {
                        package = pkgs.qemu_kvm;
                        runAsRoot = true;
                        swtpm.enable = true;
                };
        };

        sops = {
                defaultSopsFile = ../secrets.yaml;
                validateSopsFiles = false; # https://youtu.be/gdxlc5a6ne0 his was false
                age = {
                        # I generated a key from this host's public ssh host key
                        # I added it to .sops.yaml, so it can be used to decrypt 
                        # Here I tell sops-nix(?) about my host's private ssh host key so it can import it automatically as an age key
                        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
                        # this is where it will store the converted/imported age key
                        keyFile = "/var/lib/sops-nix/key.txt";
                        # generate a key from the sshKeyPaths if the key specified above doesn't exist
                        generateKey = true;
                };
                secrets = {
                        # Secrets get output to /run/secrets unencrypted but only accessible to root -
                        #  until we specify otherwise.
                        # E.g. /run/secrets/msmtp-password
                        # Secrets required for user creation need to be handled slightly differently -
                        #  since sops-nix normally runs after users have been created by nixos so    -
                        #  appropriate ownership/permissions can be set, but this can't happen for   -
                        #  user passwords, because the user won't have been created yet.
                        # The provided solution is that setting neededForUsers extracts to           -
                        # /run/secrets-for-users before user creation, and owners can't be set for   -
                        # those files.

                        axie-password.neededForUsers = true;
                        snuppy-password.neededForUsers = true;
                };
        };
        # Makes the passwords of users controlled only by nixos config
        # Required to set passwords with sops-nix
        users.mutableUsers = false; 

        users.users.snuppy = {
                extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
                description = "snuppy";
                hashedPasswordFile = config.sops.secrets.snuppy-password.path;
                isNormalUser = true;
        };
        users.users.axie = {
                isNormalUser = true;
                hashedPasswordFile = config.sops.secrets.axie-password.path;
                extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
        };

        security.sudo.extraConfig = ''
          Defaults timestamp_timeout=120 # only ask for passwd every 120min
        '';

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
        stylix.autoEnable = true;

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

        services.fstrim.enable = true;

        boot.kernelPackages = pkgs.linuxPackages_6_6;

        networking.hostId = "7d1d9835";
        boot.supportedFilesystems = [ "zfs" ];
        boot.zfs.extraPools = [ "tank" ];

        # Gemini :/ says this makes nixos continue to get latest closed source firmware
        hardware.enableRedistributableFirmware = true;

        services.tailscale.enable = true;

        environment.systemPackages = with pkgs; [
                libfido2
                #swaynotificationcenter
                #hyprpolkitagent
                #waybar
                #swww
                #rofi
        ];

        programs.ssh = {
                # snp-nuc1nix 192.168.30.65
                # snp-des2nix 192.168.30.174
                # snp-des3nix 192.168.30.144
                extraConfig = "
                        Host snp-nuc1nix
                        Hostname snp-nuc1nix.tailf46592.ts.net
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
        #services.pcscd.enable = true;
        # yubikey sudo: https://nixos.wiki/wiki/Yubikey
        #security.pam.services = {
        #        login.u2fAuth = true;
        #        sudo.u2fAuth = true;
        #};

        networking.hostName = "snp-des1nix";
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

        hardware.graphics = {
                enable = true;
        };
        services.xserver.videoDrivers = ["nvidia"];
        hardware.nvidia = {

                # Modesetting is required.
                modesetting.enable = true;

                # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
                # Enable this if you have graphical corruption issues or application crashes after waking
                # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
                # of just the bare essentials.
                powerManagement.enable = false;

                # Fine-grained power management. Turns off GPU when not in use.
                # Experimental and only works on modern Nvidia GPUs (Turing or newer).
                powerManagement.finegrained = false;

                # Use the NVidia open source kernel module (not to be confused with the
                # independent third-party "nouveau" open source driver).
                # Support is limited to the Turing and later architectures. Full list of 
                # supported GPUs is at: 
                # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
                # Only available from driver 515.43.04+
                # -
                # > An important note to take is that the option hardware.nvidia.open should only be set to false if you have a GPU with an older architecture than Turing (older than the RTX 20-Series). Also, OBS NVENC support does not seem to work currently with the open drivers. 
                open = true; # so I guess I want it anyway?

                # Enable the Nvidia settings menu,
                # accessible via `nvidia-settings`.
                nvidiaSettings = true;

                # Optionally, you may need to select the appropriate driver version for your specific GPU.
                package = config.boot.kernelPackages.nvidiaPackages.production;
        };


        # Enable KDE !
        services.displayManager.sddm.enable = true;
        services.displayManager.sddm.wayland.enable = true;
        services.desktopManager.plasma6.enable = true;

        # Hyprland...
        #programs.hyprland.enable = true;
        # optionally hint electron apps to use wayland?:
        #environment.sessionVariables.NIXOS_OZONE_WL = "1";

        # Enable GNOME !
        #services.displayManager.gdm.enable = true;
        #services.desktopManager.gnome.enable = true;

        # To disable installing GNOME's suite of applications
        # and only be left with GNOME shell.
        #services.gnome.core-apps.enable = false;
        #services.gnome.core-developer-tools.enable = false;
        #services.gnome.games.enable = false;
        #environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];

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

        nixpkgs.config.allowUnfree = true;
        nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
