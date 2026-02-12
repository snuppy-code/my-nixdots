{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.vscode = {
    # https://home-manager-options.extranix.com/?query=vscode&release=master
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      rust-lang.rust-analyzer

      #bbenoist-nix
      jnoortheen.nix-ide
      arrterian.nix-env-selector

      usernamehw.errorlens

      redhat.java

      ms-python.vscode-pylance
      ms-python.python
      ms-python.debugpy
      ms-python.pylint
      ms-python.black-formatter

      myriad-dreamin.tinymist
    ];
    userSettings = {
      "files.autoSave" = "off";
      "extensions.autoUpdate" = false;
      "update.mode" = "none";
      "[nix]"."editor.tabSize" = 2;
      "chat.agent.enabled" = false;
      "chat.commandCenter.enabled" = false;
      "inlineChat.accessibleDiffView" = "off";
      "terminal.integrated.initialHint" = false;
      "redhat.telemetry.enabled" = true;
      "tinymist.fontPaths" = [
        "./"
      ];
      "workbench.remoteIndicator.showExtensionRecommendations" = false;
      "explorer.confirmDelete" = false;
      # pylint wrong about pygame-ce, whitelist it
      # https://www.reddit.com/r/pygame/comments/lsg4l1/module_pygame_has_no_quit_or_any_other_members/
      # https://www.reddit.com/r/pygame/comments/lsg4l1/module_pygame_has_no_quit_or_any_other_members/
      # and pylint overly aggressive, chill out whiteboy
      "pylint.args" = [
        "--extension-pkg-whitelist=pygame"
        "--disable=C0114" # missing-module-docstring
        "--disable=C0115" # missing-class-docstring
        "--disable=C0116" # missing-function-docstring (or method)
      ];
    };
    profiles.snuppy.extensions = with pkgs.vscode-extensions; [
      sumneko.lua
    ];
    keybindings = [
      {
        key = "ctrl+c";
        command = "editor.action.clipboardCopyAction";
        when = "textInputFocus";
      }
      # this IS an ai keybinding but I will probably not run into it,, I should expand this
      {
        "key" = "ctrl+shift+a";
        "command" = "-workbench.action.chat.focusConfirmation";
        "when" = "accessibilityModeEnabled && chatIsEnabled";
      }
      # disable recent-editors keybinds
      {
        "key" = "ctrl+shift+tab";
        "command" = "-workbench.action.quickOpenLeastRecentlyUsedEditorInGroup";
        "when" = "!activeEditorGroupEmpty";
      }
      {
        "key" = "ctrl+tab";
        "command" = "-workbench.action.quickOpenPreviousRecentlyUsedEditorInGroup";
        "when" = "!activeEditorGroupEmpty";
      }
      # change keybinds for next/previous -editors to ctrl+tab & ctrl+shift+tab
      {
        "key" = "ctrl+tab";
        "command" = "workbench.action.nextEditor";
      }
      {
        "key" = "ctrl+pagedown";
        "command" = "-workbench.action.nextEditor";
      }
      {
        "key" = "ctrl+shift+tab";
        "command" = "workbench.action.previousEditor";
      }
      {
        "key" = "ctrl+pageup";
        "command" = "-workbench.action.previousEditor";
      }
    ];
  };
}
