{ config, pkgs, inputs, ... }:

{
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
                        vscode
                        vlc
                        mpv
                        gparted
                        code
                        caligula
                        freecad
                        processing
                        gnome-boxes
                        jdk
                        solaar
                        nextcloud-client
                        super-productivity
        ]; 

        # ~/.config
        xdg.configFile."libvirt/qemu.conf".text = ''
                # Taken from https://nixos.wiki/wiki/Libvirt cuz might be needed for gnome-boxes

                # Adapted from /var/lib/libvirt/qemu.conf
                # Note that AAVMF and OVMF are for Aarch64 and x86 respectively
                nvram = [ "/run/libvirt/nix-ovmf/AAVMF_CODE.fd:/run/libvirt/nix-ovmf/AAVMF_VARS.fd", "/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd" ]
        '';



#programs.spicetify.enable = true;

        stylix.targets.firefox.profileNames = [ "default" "ax" ];
        stylix.targets.firefox.enable = true;
        stylix.targets.kitty.enable = true;


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


# HYPRLAND !!
#wayland.windowManager.hyprland.enable = true;
# Optionally, hint Electron apps to use Wayland??!?
#home.sessionVariables.NIXOS_OZONE_WL = "1";
#wayland.windowManager.hyprland.settings = {
#  "$mod" = "SUPER";
#  bind =
#    [
#      "$mod, Return, exec, kitty"
#      
#      "$mod, F, exec, firefox"
#      ", Print, exec, grimblast copy area"
#    ]
#    ++ (
#      # workspaces
#      # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
#      builtins.concatLists (builtins.genList (i:
#          let ws = i + 1;
#          in [
#            "$mod, code:1${toString i}, workspace, ${toString ws}"
#            "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
#          ]
#        )
#        9)
#    );
#};


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
