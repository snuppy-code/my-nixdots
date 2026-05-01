{
  config,
  pkgs,
  inputs,
  ...
}: {
  nix.settings.trusted-users = ["root" "snuppy"];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 14d --keep 10";
    flake = "/home/snuppy/.dots";
  };
  # BLUNT HAMMER okay we dont need dat
  #  nix.gc = {
  #    automatic = true;
  #    dates = "weekly";
  #    options = "--delete-older-than 7d";
  #  };

  sops.secrets.snuppy-password.neededForUsers = true;
  users.users.snuppy = {
    description = "snuppy";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "adbusers"
      "libvirtd"
      "dialout"
    ];
    hashedPasswordFile = config.sops.secrets.snuppy-password.path;
  };

  services.udev.packages = [pkgs.yubikey-personalization]; #unsure why I have this

  hardware.bluetooth.enable = true;
  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # sound with pipewire.
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

  # note that "kvm-intel" and "kvm-amd" kernelModules are set in laptop and desktop respectively !
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  # https://userbase.kde.org/KDEConnect#:~:text=can%27t%20see%20each%20other
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 1714;
      to = 1764;
    }
  ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 1714;
      to = 1764;
    }
  ];

  services.flatpak.enable = true;

  # Needed for some WINE stuff,, (?)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    libGL
    #xorg.libX11
    #xorg.libXext
    #xorg.libXrender
    #glib
    #alsa-lib
    #fontconfig
    #freetype
    #zlib
  ];

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
      thunar-vcs-plugin
    ];
  };
  services.tumbler.enable = true;
  programs.xfconf.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # https://nix-community.github.io/stylix/options/modules/firefox.html
  # about:profiles
  #programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    file-roller
    unzip
    zip
    p7zip
    gnutar
    #xarchiver

    libfido2
    cage
    spice-vdagent

    sddm-astronaut
  ];
}
