{
  config,
  pkgs,
  inputs,
  ...
}: {
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
  stylix.image = ./wallpapers/highres/wp3.png;
  # The generated color scheme can be viewed at /etc/stylix/palette.html on NixOS, or at ~/.config/stylix/palette.html on Home Manager.
  #stylix.polarity = "dark";
  stylix.fonts = {
    #serif = {
    #  package = pkgs.dejavu_fonts;
    #  name = "DejaVu Serif";
    #};
    #sansSerif = {
    #  package = pkgs.dejavu_fonts;
    #  name = "DejaVu Sans";
    #};
    monospace = {
      package = pkgs.nerd-fonts._0xproto;
      name = "0xProto Nerd Font";
    };
    #emoji = {
    #  package = pkgs.noto-fonts-color-emoji;
    #  name = "Noto Color Emoji";
    #};
  };
  stylix.autoEnable = true;

  programs.spicetify = {
    enable = true;
    #theme = pkgs.lib.mkForce inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system}.themes.catppuccin;
  };

  fonts.packages = with pkgs; [
    nerd-fonts._0xproto
    nerd-fonts.jetbrains-mono
    nerd-fonts.adwaita-mono
    nerd-fonts.agave
    nerd-fonts.arimo
    nerd-fonts.aurulent-sans-mono
    nerd-fonts.bigblue-terminal
    nerd-fonts.caskaydia-mono
    nerd-fonts.commit-mono
    nerd-fonts.departure-mono
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.go-mono
    nerd-fonts.inconsolata
    nerd-fonts.iosevka-term
    nerd-fonts.iosevka-term-slab
    nerd-fonts.overpass
    nerd-fonts.sauce-code-pro
    nerd-fonts.tinos
  ];
}

