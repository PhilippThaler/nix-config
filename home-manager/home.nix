{
  config,
  pkgs,
  lib,
  ...
}: let
  scrolly = pkgs.callPackage ../pkgs/scrolly {};
  siggy = pkgs.callPackage ../pkgs/siggy {};
  cymbal = pkgs.callPackage ../pkgs/cymbal {};
in {
  # Auto-import modules: a flat foo.nix is used directly, a foo/ dir uses foo/default.nix
  imports = builtins.map (
    m: let
      s = builtins.readDir ./modules;
      t = s.${m};
    in
      if t == "directory"
      then ./modules/${m}/default.nix
      else ./modules/${m}
  ) (builtins.sort (a: b: a < b) (builtins.attrNames (lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".nix" n || t == "directory") (builtins.readDir ./modules))));

  home.username = "philipp";
  home.homeDirectory = "/home/philipp";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
  home.packages = import ./packages.nix {inherit pkgs scrolly siggy cymbal;};

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
      cd = "z";
      cdi = "zi";
      sctl = "sudo systemctl";
      reboot = "systemctl reboot";
      ansible-playbook = "ansible-playbook --diff";
      rm = "gtrash put";
      restore = "gtrash r";
      rmd = "command rm";
      tp = "gtrash put";

      zshconfig = "nvim ~/.zshrc";
      zshenv = "nvim ~/.zshenv";
      nvimconfig = "cd ~/.config/nvim && nvim init.lua && cd -";
      swayconfig = "nvim ~/.config/sway/config";
      wbconf = "cd ~/.config/waybar && nvim ~/.config/waybar/config && cd -";
      nixconf = "cd ~/nix-config && nvim && cd -";
      nixrebuild = "cd ~/nix-config && git add . && sudo nixos-rebuild switch --flake ~/nix-config#nixos && cd -";
      nixupdate = "cd ~/nix-config && update-releases && nix flake update && nixrebuild && cd - && notify-send 'Nix Update Complete'";
      mutt = "neomutt";
      ranger = "yazi";
      open = "gio open";
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

    envExtra = ''
      export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
      export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=2'
      export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=green,fg=white,bold'
      export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'
      export POWERLEVEL9K_MODE='nerdfont-complete'
    '';

    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        fpath+=("${pkgs.zsh-completions}/share/zsh/site-functions")
      '')
      (lib.mkOrder 1000 ''
        # Reset terminal after ssh dies
        ssh() {
          command ssh -Y "$@"
          local -i rc=$?
          if (( rc == 255 )); then
            printf '\e[?1049l'  # exit alternate screen
            tput reset
          fi
          return $rc
        }

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

  # ── Dotfiles ──────────────────────────────────────────────────────
  xdg.configFile = {
    "gammastep/config.ini".source = ./dotfiles/gammastep/config.ini;
    "xdg-terminals.list".text = "kitty.desktop\n";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
      "image/*" = "imv.desktop";
      "text/*" = "nvim.desktop";
      "inode/directory" = "yazi.desktop";
      "x-scheme-handler/mailto" = "neomutt.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/ftp" = "librewolf.desktop";
      "x-scheme-handler/chrome" = "librewolf.desktop";
      "text/html" = "librewolf.desktop";
      "application/x-extension-htm" = "librewolf.desktop";
      "application/x-extension-html" = "librewolf.desktop";
      "application/x-extension-shtml" = "librewolf.desktop";
      "application/xhtml+xml" = "librewolf.desktop";
      "application/x-extension-xhtml" = "librewolf.desktop";
      "application/x-extension-xht" = "librewolf.desktop";
    };
  };

  home.file =
    {
      ".p10k.zsh".source = ./dotfiles/p10k.zsh;
      # scrolly waybar module (built from Go source in pkgs/scrolly)
      "bin/scrolly".source = "${scrolly}/bin/scrolly";
      "bin/scrolly".executable = true;
    }
    // lib.mapAttrs' (name: _: {
      name = "bin/" + name;
      value = {
        source = ./bin + "/${name}";
        executable = true;
      };
    })
    (builtins.readDir ./bin);
}
