{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.weathr.homeModules.weathr
  ];

  programs.weathr = {
    enable = true;
    settings = {
      hide_hud = true;
    };
  };

  #home.sessionVariables = {
  #    NH_FLAKE = "/home/snuppy/.dots";
  #  };

  stylix.targets.firefox.profileNames = ["default" "ax"];
  stylix.targets.firefox.enable = true;
  stylix.targets.kitty.enable = true;

  programs.kitty = {
    enable = true;
    enableGitIntegration = true;
    shellIntegration = {
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    extraConfig = ''

    '';
  };

  # GTK theming settings
  gtk = {
    enable = true;
    #Icon Theme
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      # package = pkgs.kdePackages.breeze-icons;
      # name = "Breeze-Dark";
    };
  };

  #home.file.".gtkrc-2.0".force = true;
  gtk.gtk2.force = true;

  # ~/.config
  xdg.configFile."libvirt/qemu.conf".text = ''
    # Taken from https://nixos.wiki/wiki/Libvirt cuz might be needed for gnome-boxes

    # Adapted from /var/lib/libvirt/qemu.conf
    # Note that AAVMF and OVMF are for Aarch64 and x86 respectively
                    nvram = [ "/run/libvirt/nix-ovmf/AAVMF_CODE.fd:/run/libvirt/nix-ovmf/AAVMF_VARS.fd", "/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd" ]
  '';

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.packages = with pkgs; [
    yubikey-manager
    yubioath-flutter
    #super-productivity
    killall
    claude-code

    google-chrome
    firefox
    vesktop
    element-desktop
    gajim
    # fluffychat
    #nheko # requires olm which has like 3 cves?
    #cinny-desktop # nixpkgs is waiting on cinny which is waiting on something else, "CSF" or sumn?

    typst
    noto-fonts
    noto-fonts-color-emoji
    corefonts
    vista-fonts

    #gnome-solanum # no history/stats
    #gnome-pomodoro # slightly less pretty than:
    pomodoro-gtk
    normcap
    #input-leap # stuck on 'starting'
    #deskflow
    protonvpn-gui
    solaar
    gnome-system-monitor
    gnome-font-viewer
    gnome-clocks
    jstest-gtk
    qalculate-qt
    spotify
    obsidian
    nextcloud-client
    # mupdf
    krita
    aseprite
    blender
    obs-studio
    davinci-resolve
    audacity
    freecad

    protonplus
    (prismlauncher.override {jdks = [jdk8 jdk17 jdk21 jdk25];})
    lutris
    bottles

    gnome-boxes
    gparted
    veracrypt

    processing
    github-desktop
    zed-editor
    #sublime4

    vlc
    mpv
    ffmpeg
    #easyeffects
    #pavucontrol

    sops
    age

    cloc

    #arduino-ide
    arduino
    avrdude
    #avrlibc

    jdk
    # (python314.withPackages (ps: with ps; [pygame-ce]))
    python314
    rustup
    #cargo
    #rustc
    #clippy
    cargo-flamegraph
    samply
    cargo-public-api
    cargo-modules
    bacon
    gcc
  ];
}
