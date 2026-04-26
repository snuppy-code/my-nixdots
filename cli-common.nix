{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mycli = {
    username = lib.mkOption {
      #default omitted so you must specify a username
      type = lib.types.str;
      description = "User to set up CLI stuff, some of it requires a user";
    };
  };
  config = {
    environment.systemPackages = with pkgs; [
      lazygit
      bat
      lnav
      iw
      dig
      whois
      git
      delta
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
      tree
    ];

    services.locate = {
      enable = true;
      package = pkgs.plocate;
    };

    environment.shells = with pkgs; [
      nushell
    ];
    users.users.${config.mycli.username}.shell = pkgs.nushell;

    environment.variables.EDITOR = "nvim";

    home-manager.users.${config.mycli.username} = {pkgs, ...}: {
      stylix.targets.nushell.enable = true;
      stylix.targets.starship.enable = true;
      stylix.targets.nvf.enable = true;

      home.packages = with pkgs; [
        starship
        carapace
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

    programs.nvf = {
      enable = true;
      settings.vim = {
        theme.enable = true;
        lsp = {
          enable = true;
          formatOnSave = true;
          lightbulb.enable = true;
          trouble.enable = true;
        };
        statusline.lualine.enable = true;
        telescope.enable = true;
        autocomplete.blink-cmp.enable = true;
        git = {
          enable = true;
          gitsigns.enable = true;
          gitsigns.codeActions.enable = false; # throws an annoying debug message
          neogit.enable = true;
        };
        tabline = {
          nvimBufferline.enable = true;
        };
        filetree = {
          neo-tree = {
            enable = true;
          };
        };
        visuals = {
          nvim-scrollbar.enable = true;
          nvim-web-devicons.enable = true;
          nvim-cursorline.enable = true;
          cinnamon-nvim.enable = true;
          fidget-nvim.enable = true;

          highlight-undo.enable = true;
          indent-blankline.enable = true;

          # Fun
          cellular-automaton.enable = true;
        };
        languages = {
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;
          nix = {
            enable = true;
            format.type = ["alejandra"];
          };
          markdown.enable = true;
          rust = {
            enable = true;
            extensions.crates-nvim.enable = true;
          };
          bash.enable = true;
          clang.enable = false;
          css.enable = false;
          html.enable = false;
          json.enable = true;
          sql.enable = false;
          java.enable = true;
          kotlin.enable = false;
          ts.enable = false;
          go.enable = true;
          lua.enable = true;
          zig.enable = false;
          python.enable = true;
          typst.enable = true;
          toml.enable = true;
          # xml.enable = true;
          julia.enable = false;
          gleam.enable = false;
          haskell.enable = false;
        };
      };
    };
  };
}
