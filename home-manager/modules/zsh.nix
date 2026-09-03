{pkgs, lib, config, ...}: {
  # ── zsh (replaces antigen: plugins come from nixpkgs) ─────────────
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=2";
      strategy = ["history" "completion"];
    };

    fastSyntaxHighlighting = {
      enable = true;
    };

    historySubstringSearch = {
      enable = true;
      # History substring search on arrow keys
      searchDownKey = "$terminfo[kcud1]";
      searchUpKey = "$terminfo[kcuu1]";
    };

    history = {
      size = 10000;
      save = 10000;
      path = "${config.xdg.dataHome}/zsh/zsh_history";
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
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    envExtra = ''
      export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=green,fg=white,bold'
      export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'
      export POWERLEVEL9K_MODE='nerdfont-complete'
    '';

    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        fpath+=("${pkgs.zsh-completions}/share/zsh/site-functions")
      '')
      (lib.mkOrder 1000 ''
        # Accept autosuggestion with Ctrl+Space
        bindkey '^ ' autosuggest-accept

        # powerlevel10k prompt (ported from ~/.zsh/.p10k.zsh)
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

        # Allow `$ command` (for pasting snippets that include the prompt)
        function $ { "$@" }

        compdef _ap_completion ap
      '')
    ];

    siteFunctions = {
      # Reset terminal after ssh dies
      ssh = ''
        command ssh -Y "$@"
        local -i rc=$?
        if (( rc == 255 )); then
          printf '\e[?1049l'  # exit alternate screen
          tput reset
        fi
        return $rc
      '';
      # Run playbooks from the homelab ansible repo from anywhere
      ap = ''
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
      '';

      _ap_completion = ''
        if [[ -d "$ANSIBLE_BASE_DIR/playbooks" ]]; then
            local -a files
            files=( "$ANSIBLE_BASE_DIR"/playbooks/*.y*ml(N:t) )
            if (( ''${#files} > 0 )); then
                compadd -M 'm:{a-zA-Z}={a-zA-Z} l:|=* r:|=*' -a files
                return 0
            fi
        fi
      '';
    };
  };
}
