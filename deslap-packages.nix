{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    protonvpn-gui
    iw
    dig
    whois
    yubikey-manager
    yubioath-flutter
    solaar

    qalculate-qt
    jstest-gtk
    protonplus
    gnome-clocks
    thunar
    xfce.tumbler

    firefox
    vesktop
    element-desktop
    # fluffychat
    noto-fonts
    noto-fonts-color-emoji
    #nheko # requires olm which has like 3 cves?
    #cinny-desktop # nixpkgs is waiting on cinny which is waiting on something else, "CSF" or sumn?

    lutris
    bottles
    (prismlauncher.override {jdks = [jdk8 jdk17 jdk21 jdk25];})

    #dino
    gajim
    spotify
    obsidian
    nextcloud-client
    mupdf
    krita
    aseprite
    blender
    obs-studio
    davinci-resolve
    audacity
    github-desktop
    freecad
    processing
    gnome-boxes
    gnome-font-viewer
    veracrypt
    #sublime4
    vivaldi

    vlc
    mpv
    ffmpeg

    #arduino-ide
    arduino
    avrdude
    #avrlibc

    gparted
    jdk
    (python314.withPackages (ps: with ps; [pygame-ce]))
    #cargo
    rustup
    #rustc
    #clippy
    cargo-flamegraph
    samply
    cargo-public-api
    cargo-modules
    bacon
    gcc
    caligula
    sops
    age
    cloc
    typst

    corefonts
    vista-fonts

    #easyeffects
    #pavucontrol
  ];
}
