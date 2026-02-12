{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../vscode-home.nix
    ../deslap-packages.nix
  ];

  home.packages = with pkgs; [
    geteduroam
    #geteduroam-cli
    networkmanager
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
