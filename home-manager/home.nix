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

  # ── zoxide / fzf (zsh-integration is set up in modules/zsh.nix) ──
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
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
