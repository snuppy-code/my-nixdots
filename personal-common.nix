{
  config,
  pkgs,
  inputs,
  ...
}: {
  nix.settings.trusted-users = ["root" "snuppy"];

  mycli.username = "snuppy";
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  # home-manager.users.snuppy = import ./snp-des1nix/snuppy-home.nix; # I specify this in the flake instead cuz this file also goes for snp-lap1nix
  home-manager.extraSpecialArgs = {inherit inputs;};
  home-manager.backupFileExtension = "backup";

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

  services.udev.packages = [pkgs.yubikey-personalization];

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

    gnomeExtensions.emoji-copy
    gnomeExtensions.appindicator
  ];
}
