{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages =
    with pkgs; [
      yubikey-manager
      yubioath-flutter

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
      protonvpn-gui
      solaar
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
      #(python314.withPackages (ps: with ps; [pygame-ce]))
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
