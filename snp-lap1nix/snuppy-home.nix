{ config, pkgs, inputs, ... }:

{
	#imports = [
	#	inputs.spicetify-nix.homeManagerModules.default
	#];

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
		vscode
		vlc
		mpv
		wezterm
		lnav
		plocate
		carapace
		starship
	]; 

	#programs.spicetify.enable = true;
  
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

  programs.yazi.enable = true;

  #programs.wezterm = {
  #  enable = true;
  #  enableZshIntegration = true;
  #  enableBashIntegration = true;
  #  extraConfig = config.lib.file.mkOutOfStoreSymlink ./.wezterm.lua;
  #};
  
  xdg.configFile."wezterm/wezterm.lua".source = ./.wezterm.lua;

  programs.nushell = {
    enable = true;
    extraConfig = ''
	$env.config.show_banner = false
	#$env.config.shell_integration = {
	#	osc2: true
	#	osc7: true
	#	osc8: true
	#	osc9_9: true
	#	osc133: true
	#	osc633: true
	#	reset_application_mode: true
	#}
    '';
    shellAliases = {
      vi = "nvim";
      vim = "nvim";
      nano = "nvim";
      l = "ls";
      ll = "ls -l";
    };
  };
  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
	error_symbol = "[➜](bold red)";
      };
    };
  };


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
