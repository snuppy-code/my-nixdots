{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
  ];

  home.packages = with pkgs; [
    protonvpn-gui
    yubikey-manager
    yubioath-flutter
    qalculate-qt
    vesktop
    spotify
    obsidian
    krita
    blender
    vscode-fhs
    vlc
    mpv
    gparted
    caligula
    geteduroam
    #geteduroam-cli
    networkmanager
    #jdk25_headless
    jdk
    solaar
    freecad
    nextcloud-client
    #super-productivity
    #android-tools
    gnome-boxes
    sops
    easyeffects
    gnome-font-viewer
    github-desktop
    audacity
  ];

  #programs.spicetify.enable = true;

  #stylix.targets.firefox.profileNames = [ "default" "ax" ];
  #stylix.targets.firefox.enable = true;
  #stylix.targets.kitty.enable = true;

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

  #home.file.".gtkrc-2.0".force = true;
  gtk.gtk2.force = true;

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";
}
