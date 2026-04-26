# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
  ];

  users.users.snuppy.openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILywcKsOrkjA6Zz0Nzv4zSkVSc67Yp8e1FZZql7AETTLAAAABHNzaDo= snuppy.code@pm.me"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILDkgmUlpM3cGE0MDHU0QyCtspkpImLjQVpkU7ihv5P9 mend@snp-des2nix"
  ];

  services.logind.settings.Login = {
    # one of "ignore", "poweroff", "reboot", "halt", "kexec", "suspend", "hibernate", "hybrid-sleep", "suspend-then-hibernate", "lock"
    HandleLidSwitch = "hybrid-sleep"; # like sleep (suspend) but also prepares hibernation, so if battery runs out I can still resume as if from hibernation
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "ignore";
  };

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

  # Something something yubikey
  services.pcscd.enable = true;
  # yubikey sudo: https://nixos.wiki/wiki/Yubikey
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.theme = "sddm-astronaut-theme";
  services.displayManager.sddm.extraPackages = [pkgs.sddm-astronaut];

  services.desktopManager.plasma6.enable = true;

  # --- laptop hotspot from ethernet thing,, ---
  #
  # sops.secrets.snuppy-password.neededForUsers = true; # not needed here? cuz not for a user?
  # sops.templates."lilith-env".content = ''
  #   LILITH_PASSWORD=${config.sops.placeholder."lilith-password"}
  # '';
  networking.networkmanager.ensureProfiles = {
    # environmentFiles = [ config.sops.templates."lilith-env".path ];
    profiles = {
      "lilith" = {
        connection = {
          id = "lilith";
          uuid = "c38e3888-563f-4a79-b745-b9beb8a852a2"; # random one I generated with uuidgen
          type = "wifi";
          interface-name = "wlp1s0f0";
          autoconnect = false; # start on boot
        };
        wifi = {
          mode = "ap";
          ssid = "Lilith";
          band = "bg"; # force 2.4GHz to bypass intel LAR blocks
          channel = 6; # Forces a standard channel, preventing 12/13 issues
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          # psk = "$LILITH_PASSWORD"; # config.sops.secrets.snuppy-password.path; ?
          psk = "terminaldogma"; # config.sops.secrets.snuppy-password.path; ?
          pmf = 1; # 1 = Disable PMF to maximize compatibility for VR/IoT
        };
        ipv4 = {
          method = "shared"; # tells NM to act as router/DHCP server
        };
        ipv6 = {
          method = "ignore";
        };
      };
    };
  };
  networking.firewall.interfaces.wlp1s0f0 = {
    allowedUDPPorts = [53 67]; #67 - DHCP, 53 - DNS
    allowedTCPPorts = [53]; #53 - DNS
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
