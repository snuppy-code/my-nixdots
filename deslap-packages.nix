{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    protonvpn-gui

    yubikey-manager
    yubioath-flutter
    solaar

    qalculate-qt

    firefox
    vesktop
    element-desktop
    # fluffychat
    noto-fonts
    noto-fonts-color-emoji
    #nheko # requires olm which has like 3 cves?
    # cinny-desktop # same 

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

    vlc
    mpv

    gparted
    jdk
    (python314.withPackages (ps: with ps; [pygame-ce]))
    cargo
    rustc
    gcc
    caligula
    sops
    age
    cloc
    typst

    corefonts
    vista-fonts

    easyeffects
    pavucontrol
  ];
}
