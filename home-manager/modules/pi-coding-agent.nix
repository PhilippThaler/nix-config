{
  pkgs,
  config,
  ...
}: {
  programs.pi-coding-agent = {
    enable = true;
    configDir = "${config.home.homeDirectory}/.config/pi";

    # Runtime deps for pi-installed packages (npm registry installs)
    extraPackages = [
      pkgs.nodejs_22
    ];

    settings = {
      lastChangelogVersion = "0.84.2";
      defaultProvider = "opencode-go";
      defaultModel = "deepseek-v4-flash-vision-exp";
      defaultThinkingLevel = "high";
      enabledModels = [
        "opencode-go/deepseek-v4-flash"
        "opencode-go/deepseek-v4-flash-vision-exp"
        "opencode-go/deepseek-v4-pro"
        "opencode-go/qwen3.8-flash"
        "opencode-go/qwen3.8-max"
        "opencode-go/kimi-k2.7-code"
        "opencode-go/kimi-k3"
        "opencode-go/hy4-preview"
      ];
      "observational-memory" = {
        model = {
          provider = "opencode-go";
          id = "deepseek-v4-flash";
          thinking = "low";
        };
      };
      "pi-fork" = {
        defaultEffort = "balanced";
        effortProfiles = {
          fast = {
            provider = "opencode-go";
            id = "deepseek-v4-flash";
            thinking = "medium";
          };
          balanced = {
            provider = "opencode-go";
            id = "deepseek-v4-pro";
            thinking = "high";
          };
          deep = {
            provider = "opencode-go";
            id = "kimi-k2.7-code";
            thinking = "xhigh";
          };
        };
      };
      theme = "dark";
      hideThinkingBlock = false;
      packages = [
        "npm:@gotgenes/pi-permission-system@20.10.0"
        "npm:pi-web-access@0.13.0"
        "npm:@juicesharp/rpiv-todo@2.0.0"
        "npm:@juicesharp/rpiv-ask-user-question@2.0.0"
        "npm:@juicesharp/rpiv-advisor@2.0.0"
        "npm:@juicesharp/rpiv-btw@2.0.0"
        "npm:@ff-labs/pi-fff@0.10.1"
        "https://github.com/elpapi42/pi-fork@4a09af4ef5276d68f0d4321d033fa0f3f0ef2954"
        "https://github.com/elpapi42/pi-observational-memory@27a5195eaf90e4e2ca1302e3a31d4bb14df982a5"
        "https://github.com/MasuRii/pi-rtk-optimizer@d155d253cb2f1358e34e717d47a82ebccb08cb8e"
        "npm:@gotgenes/pi-subagents@21.2.2"
        "https://github.com/Dwsy/pi-session-manager@c3e68d85ec8a2a818cb0ff1b0593bef71256054b"
        "npm:pi-powerline-footer@0.16.0"
      ];
    };

    keybindings = {
      "app.model.cycleForward" = [];
      "app.model.cycleBackward" = [];
      "tui.select.up" = [
        "up"
        "ctrl+p"
        "alt+k"
      ];
      "tui.select.down" = [
        "down"
        "ctrl+n"
        "alt+j"
      ];
      "tui.editor.deleteWordBackward" = [
        "ctrl+w"
        "alt+backspace"
        "ctrl+backspace"
      ];
      "tui.editor.deleteWordForward" = [
        "alt+d"
        "alt+delete"
        "ctrl+delete"
      ];
      "tui.editor.cursorLineStart" = [
        "home"
        "ctrl+a"
        "ctrl+home"
      ];
      "tui.editor.cursorLineEnd" = [
        "end"
        "ctrl+e"
        "ctrl+end"
      ];
    };
  };
}
