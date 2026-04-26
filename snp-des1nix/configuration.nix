# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
  ];

  users.users.snuppy.openssh.authorizedKeys.keys = [
  ];

  # gonna beat my FUCKASS friend in tiktok fruit slice game
  # virtualisation.waydroid.enable = true;

  # Something something yubikey
  #services.pcscd.enable = true;
  # yubikey sudo: https://nixos.wiki/wiki/Yubikey
  #security.pam.services = {
  #        login.u2fAuth = true;
  #        sudo.u2fAuth = true;
  #};

  programs.ssh = {
    # snp-nuc1nix 192.168.30.65
    # snp-des2nix 192.168.30.174
    # snp-des3nix 192.168.30.144
    extraConfig = "
      Host snp-nuc1nix
      Hostname snp-nuc1nix.tailf46592.ts.net
      Port 22
      User mend

      Host snp-des2nix
      Hostname snp-des2nix.tailf46592.ts.net 
      Port 22
      User mend

      Host snp-des3nix
      Hostname snp-des3nix.tailf46592.ts.net
      Port 22
      User mend
    ";
  };
  #programs.ssh.startAgent = true;

  # Enable KDE !
  #services.displayManager.sddm.enable = true;
  #services.displayManager.sddm.wayland.enable = true;
  #services.desktopManager.plasma6.enable = true;

  # Cosmic !
  # services.desktopManager.cosmic.enable = true;
  # services.displayManager.cosmic-greeter.enable = true;
  # services.flatpak.enable = true;

  # Hyprland...
  #programs.hyprland.enable = true;
  # optionally hint electron apps to use wayland?:
  #environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable GNOME !
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  # To disable installing GNOME's suite of applications
  # and only be left with GNOME shell.
  #services.gnome.core-apps.enable = false;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;
  environment.gnome.excludePackages = with pkgs; [gnome-tour gnome-user-docs];

  # dconf.settings = {
  #   "org/gnome/shell" = {
  #     disable-user-extensions = false;
  #     enabled-extensions = [
  #       "emoji-copy@felipeftn"
  #     ];
  #   };
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
