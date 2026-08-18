# Home Manager configuration — ported from ~/dotfiles (Arch machine)
{
  config,
  pkgs,
  lib,
  ...
}: let
  scrolly = pkgs.callPackage ../pkgs/scrolly {};

  # ~/bin helper scripts (ported verbatim from dotfiles/bin/bin)
  binScripts = [
    "battery-warn"
    "change-volume"
    "create-recording-source"
    "force-kill"
    "move-window"
    "powermenu"
    "recording-audio-source"
    "record-screen"
    "rofi-cheatsheet-helper"
    "screenshot-full"
    "screenshot-region"
    "screenshot-window"
    "screenshot-window-clip"
    "swayidle-daemon"
    "toggle_scratchpad"
  ];

  waybarScripts = ["bluetooth.sh" "clipboard.sh" "gammastep.sh" "notifications.sh"];
in {
  imports = [
    ./nvim.nix
  ];

  home.username = "philipp";
  home.homeDirectory = "/home/philipp";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  # ── Packages ──────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Wayland desktop
    kitty
    waybar
    rofi # Wayland-enabled build (rofi-wayland was merged upstream)
    rofimoji
    swaynotificationcenter # swaync
    swayidle
    swaylock-effects
    swaybg
    gammastep
    autotiling
    brightnessctl
    playerctl
    grim
    slurp
    wf-recorder
    wl-clipboard
    cliphist
    libnotify
    networkmanagerapplet
    pavucontrol
    pcmanfm
    wdisplays
    wtype
    jq
    mate-polkit
    pulseaudio # pactl / paplay (PipeWire pulse server)
    pipewire # pw-cli / pw-link (recording scripts)
    wireplumber # wpctl
    kdePackages.kdeconnect-kde # kdeconnect-indicator (sway autostart)
    scrolly

    # Shell / CLI
    lsd
    bat
    ripgrep
    fd
    keychain
    ranger
    tree-sitter
    highlight # ranger file previews
    atool
    mediainfo
    ffmpegthumbnailer
    poppler-utils
    w3m
    btop
    duf
    gtrash # trash CLI (`tp` alias)
    tree
    unzip
    zip
    unrar
    p7zip
    rsync
    sshfs
    nmap
    rtk

    # Dev
    neovim
    gcc # treesitter parser compilation
    gnumake
    go
    gopls
    delve
    python3
    uv
    ansible
    ansible-lint
    gh
    git-filter-repo
    nil # nix LSP
    alejandra # nix formatter
    typst
    pandoc
    pre-commit
    docker-compose
    nodejs_22

    # GUI apps
    librewolf
    spotify
    pi-coding-agent
    libreoffice-fresh
    gimp
    mpv
    imv
    zathura
    galculator
    simple-scan
    nextcloud-client
    filezilla
    inkscape
    xarchiver
  ];

  # ── Environment ───────────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    BROWSER = "librewolf";
    FZF_DEFAULT_COMMAND = ''rg --files --hidden --glob "!.git"'';
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    ANSIBLE_BASE_DIR = "$HOME/Projects/homelab-ansible";
    GOPATH = "$HOME/go";
    PI_CODING_AGENT_DIR = "$HOME/.config/pi";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/go/bin"
    "$HOME/.npm-global/bin"
  ];

  # ── zsh (replaces antigen: plugins come from nixpkgs) ─────────────
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    history = {
      size = 10000;
      save = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
    };

    shellAliases = {
      "sudo" = "sudo ";
      ":q" = "exit";
      vi = "nvim";
      ls = "lsd";
      l = "lsd -lah";
      cat = "bat";
      g = "nvim +Neogit +only";
      ssh = "ssh -Y ";
      cd = "z";
      cdi = "zi";
      sctl = "sudo systemctl";
      reboot = "systemctl reboot";
      ansible-playbook = "ansible-playbook --diff";
      rm = "echo -e 'If you want to use rm really, then use \"tp\" or \"rmd\" instead.'; false";
      rmd = "command rm";
      tp = "gtrash put";
      # config shortcuts
      zshconfig = "nvim ~/.zshrc";
      zshenv = "nvim ~/.zshenv";
      nvimconfig = "cd ~/.config/nvim && nvim init.lua && cd -";
      swayconfig = "nvim ~/.config/sway/config";
      wbconf = "cd ~/.config/waybar && nvim ~/.config/waybar/config && cd -";
      nixconf = "cd ~/nix-config";
      nixrebuild = "sudo nixos-rebuild switch --flake ~/nix-config#nixos";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "git-extras"
        "extract"
        "colored-man-pages"
        "gpg-agent"
        "nmap"
        "zsh-interactive-cd"
      ];
    };

    plugins = [
      {
        name = "fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
        file = "share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh";
      }
      {
        name = "zsh-history-substring-search";
        src = pkgs.zsh-history-substring-search;
        file = "share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh";
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    # ~/.zshenv additions (was: dotfiles/zsh/.zshenv)
    envExtra = ''
      export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
      export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=2'
      export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=green,fg=white,bold'
      export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'
      export POWERLEVEL9K_MODE='nerdfont-complete'
    '';

    # ~/.zshrc additions (was: dotfiles/zsh/.zshrc)
    initContent = lib.mkMerge [
      # zsh-completions: extra fpath entries must exist before compinit runs
      (lib.mkOrder 550 ''
        fpath+=("${pkgs.zsh-completions}/share/zsh/site-functions")
      '')
      (lib.mkOrder 1000 ''
      # Accept autosuggestion with Ctrl+Space
      bindkey '^ ' autosuggest-accept
      # History substring search on arrow keys
      bindkey "$terminfo[kcuu1]" history-substring-search-up
      bindkey "$terminfo[kcud1]" history-substring-search-down

      # powerlevel10k prompt (ported from ~/.zsh/.p10k.zsh)
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
      eval "$(zoxide init zsh)"
      eval $(keychain --eval --quiet ~/.ssh/ansible_key)
      

      # Allow `$ command` (for pasting snippets that include the prompt)
      function $ { "$@" }

      # Run playbooks from the homelab ansible repo from anywhere
      ap() {
          if [ -z "$1" ]; then
              echo "Error: Please specify a playbook."
              return 1
          fi
          local playbook="$1"
          shift
          if [[ -f "$ANSIBLE_BASE_DIR/playbooks/$playbook" ]]; then
              (cd "$ANSIBLE_BASE_DIR" && ansible-playbook --diff "playbooks/$playbook" "$@")
          else
              echo "Error: Playbook not found at $ANSIBLE_BASE_DIR/playbooks/$playbook"
              return 1
          fi
      }

      _ap_completion() {
          if [[ -d "$ANSIBLE_BASE_DIR/playbooks" ]]; then
              local -a files
              files=( "$ANSIBLE_BASE_DIR"/playbooks/*.y*ml(N:t) )
              if (( ''${#files} > 0 )); then
                  compadd -M 'm:{a-zA-Z}={a-zA-Z} l:|=* r:|=*' -a files
                  return 0
              fi
          fi
      }
      compdef _ap_completion ap
      '')
    ];
  };

  programs.zoxide.enable = true;
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # ── git ───────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      user.name = "Philipp Thaler";
      user.email = "philipp@thaler.fyi";
      init.defaultBranch = "main";
    };
  };

  # ── Cursor / GTK theming ──────────────────────────────────────────
  home.pointerCursor = {
    enable = true;
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
    size = 36;
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Qogir-dark";
      package = pkgs.qogir-icon-theme;
    };
    gtk4.theme = null;
  };

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  # ── XDG ───────────────────────────────────────────────────────────
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # ── Dotfiles (raw, ported from ~/dotfiles) ────────────────────────
  xdg.configFile =
    {
      # sway config with store-path substitution for the polkit agent
      "sway/config".text = builtins.replaceStrings ["@POLKIT_AGENT@"] ["${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1"] (builtins.readFile ./dotfiles/sway/config);

      "waybar/config".source = ./dotfiles/waybar/config;
      "waybar/style.css".source = ./dotfiles/waybar/style.css;

      "kitty/kitty.conf".source = ./dotfiles/kitty/kitty.conf;
      "kitty/current-theme.conf".source = ./dotfiles/kitty/current-theme.conf;

      "rofi".source = ./dotfiles/rofi;
      "rofi".recursive = true;

      "swaylock/config".source = ./dotfiles/swaylock/config;
      "gammastep/config.ini".source = ./dotfiles/gammastep/config.ini;
      "mimeapps.list".source = ./dotfiles/mimeapps.list;

      "ranger".source = ./dotfiles/ranger;
      "ranger".recursive = true;

      "rofi-cheatsheet-helper/cheatsheets".source = ./dotfiles/rofi-cheatsheet-helper/cheatsheets;
      "rofi-cheatsheet-helper/cheatsheets".recursive = true;
    }
    // builtins.listToAttrs (map (name: {
        name = "waybar/scripts/${name}";
        value = {
          source = ./dotfiles/waybar/scripts + "/${name}";
          executable = true;
        };
      })
      waybarScripts);

  home.file =
    {
      ".p10k.zsh".source = ./dotfiles/p10k.zsh;
      # scrolly waybar module (built from Go source in pkgs/scrolly)
      "bin/scrolly".source = "${scrolly}/bin/scrolly";
      "bin/scrolly".executable = true;
    }
    // builtins.listToAttrs (map (name: {
        name = "bin/${name}";
        value = {
          source = ./dotfiles/bin + "/${name}";
          executable = true;
        };
      })
      binScripts);
}
