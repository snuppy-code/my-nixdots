{
  config,
  pkgs,
  lib,
  ...
}: {
  config = {

    # Enable GNOME !
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    # To disable installing GNOME's suite of applications
    # and only be left with GNOME shell.
    #services.gnome.core-apps.enable = false;
    services.gnome.core-developer-tools.enable = false;
    services.gnome.games.enable = false;
    environment.gnome.excludePackages = with pkgs; [gnome-tour gnome-user-docs];

    environment.systemPackages = with pkgs; [
      gnomeExtensions.tiling-shell
      gnomeExtensions.emoji-copy
      gnomeExtensions.gsconnect
      gnomeExtensions.caffeine
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.appindicator
    ];
  }

  # dconf.settings = {
  #   "org/gnome/shell" = {
  #     disable-user-extensions = false;
  #     enabled-extensions = [
  #       "emoji-copy@felipeftn"
  #       "dash-to-dock@micxgx.gmail.com"
  #     ];
  #   };
  # };
}