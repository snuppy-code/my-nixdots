{ config, pkgs, lib, ... }: {
        options.mycli = {
                username = lib.mkOption {
                        #default omitted so you must specify a username
                        type = lib.types.str;
                        description = "User to set up CLI stuff, some of it requires a user";
                };
        };
        config = {
                environment.systemPackages = with pkgs; [
                        python314
                        git
                        delta
                        neovim
                        fzf
                        ripgrep
                        fd
                        fastfetch
                        btop
                        pciutils
                        lshw
                        inxi
                        iperf
                        clinfo
                        plocate
                        caligula
                        #vulkan-tools
                        #nushell
                ];
                services.locate = {
                        enable = true;
                        package = pkgs.plocate;
                };
                environment.shells = with pkgs; [
                        nushell
                ];

                programs.nvf = {
                        enable = true;
                        settings.vim = {
                                theme.enable = true;
                                lsp.enable = true;
                                statusline.lualine.enable = true;
                                telescope.enable = true;
                                autocomplete.nvim-cmp.enable = true;
                        };
                };
                users.users.${config.mycli.username}.shell = pkgs.nushell;
                home-manager.users.${config.mycli.username} = { pkgs, ... }: {

                        stylix.targets.nushell.enable = true;
                        stylix.targets.starship.enable = true;
                        stylix.targets.nvf.enable = true;

                        home.packages = with pkgs; [
                                starship
                                carapace
                                lazygit
                                bat
                                lnav
                        ]; 

                        programs.yazi.enable = true;

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
                };
        };
}
