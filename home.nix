{ config, pkgs, ... }:

{
	#home.username = "snuppy";
	#home.homeDirectory = "/home/snuppy";
	
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
		lazygit

	];



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
