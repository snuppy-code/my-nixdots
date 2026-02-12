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
    spotify
    obsidian
    nextcloud-client
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
    caligula
    sops
    cloc
    typst
    
    
    easyeffects
    pavucontrol
  ];
}
