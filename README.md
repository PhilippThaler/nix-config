# nix-config

NixOS configuration ported from my Arch dotfiles. Single command deploys the
entire system: kernel → desktop → dotfiles → user packages.

## Quick start

```bash
# Edit config
nixconf          # cd ~/nix-config

# Apply changes
nixrebuild       # sudo nixos-rebuild switch --flake ~/nix-config#nixos

# Update all packages (like pacman -Syu)
nix flake update ~/nix-config && nixrebuild

# Roll back to previous generation (from boot menu or live)
sudo nixos-rebuild switch --rollback   # live
# Boot menu: pick an older "NixOS configuration" entry
```

## Nix concepts in 60 seconds

| Arch concept            | Nix equivalent                               |
|-------------------------|----------------------------------------------|
| `pacman -S pkg`         | Add to `home.packages` or `environment.systemPackages`, rebuild |
| `pacman -Syu`           | `nix flake update && nixrebuild`             |
| `/etc/…` config files   | Declared in nix, built into `/nix/store`, symlinked |
| AUR                     | Nixpkgs (80 000+ packages) covers almost everything |
| `.pacsave` / `.pacnew`  | Doesn't exist — everything is declarative    |
| Partial upgrade hell    | Doesn't exist — atomic, transactional        |
| Broken after update     | `sudo nixos-rebuild switch --rollback` (instant) |

**Key idea:** You don't `pacman -S` packages. You declare what you want in a file
and run one command. Nix computes the exact set of packages, builds/downloads
them, and atomically switches to the new system. Old generations stay on disk
and in the boot menu — you can always go back.

## Repo structure

```
~/nix-config/
├── flake.nix                  # flake entry: pins nixpkgs + home-manager versions
├── flake.lock                 # locked revision hashes (like a lockfile)
├── README.md                  # this file
├── nixos/
│   ├── configuration.nix      # system config: kernel, drivers, services, fonts
│   └── hardware-configuration.nix  # auto-generated (disk layout, CPU, GPU)
├── home-manager/
│   ├── home.nix               # your packages, zsh, git, dotfiles
│   ├── email.nix              # neomutt + mbsync + msmtp + pass (Spacemail)
│   └── dotfiles/              # raw config files ported from ~/dotfiles
│       ├── bin/               #    ~/bin scripts (battery-warn, screenshot-*, …)
│       ├── sway/config        #    sway config (with @POLKIT_AGENT@ placeholder)
│       ├── waybar/            #    waybar config + style + scripts/
│       ├── kitty/             #    kitty.conf + current-theme.conf
│       ├── rofi/              #    rofi Catppuccin theme
│       ├── swaylock/          #    swaylock config
│       ├── gammastep/         #    gammastep config
│       ├── ranger/            #    ranger config + plugins
│       ├── rofi-cheatsheet-helper/
│       ├── mimeapps.list      #    default MIME associations
│       └── p10k.zsh           #    powerlevel10k prompt config
├── modules/                   # reusable NixOS modules (extend later)
├── overlays/                  # package overrides (extend later)
└── pkgs/
    └── scrolly/               # custom package: scrolly (go, waybar now-playing)
        ├── default.nix
        └── go.mod
```

## Architecture

This is a **flake-based** setup. The flake (`flake.nix`) pins two inputs:

- **nixpkgs** → `nixos-unstable` (rolling, like Arch)
- **home-manager** → tracks nixos-unstable

Home Manager runs **as a NixOS module** — one `nixos-rebuild switch` deploys both
the system and your user environment. No separate `home-manager switch` needed.

### Hybrid dotfile strategy

| Config             | Method                     | Why                                   |
|--------------------|----------------------------|---------------------------------------|
| zsh, git, aliases  | Home Manager **native**    | HM handles plugin wiring, env vars    |
| sway, waybar       | Raw files via `home.file`  | Complex nested config, easier to port |
| kitty, rofi, …     | Raw dotfiles               | Direct 1:1 from Arch                  |
| neovim             | **Mutable copy** (rsync)   | lazy.nvim needs write access          |
| bin scripts        | Raw files, `executable=true`| Shell scripts, no build needed       |
| scrolly            | Nix build (`buildGoModule`) | Go binary, builds from source        |

## How to do common things

### Add a package (system-wide)

Edit `nixos/configuration.nix` → `environment.systemPackages`:

```nix
environment.systemPackages = with pkgs; [
  vim
  git
  your-new-package   # ← add here
];
```

### Add a package (just for your user)

Edit `home-manager/home.nix` → `home.packages`:

```nix
home.packages = with pkgs; [
  kitty
  your-new-package   # ← add here
];
```

Rebuild: `nixrebuild`

### Search for a package

```bash
nix search nixpkgs <keyword>
# or browse: https://search.nixos.org/packages
```

### Modify a dotfile (sway, waybar, kitty, …)

Edit the file in `home-manager/dotfiles/`, then rebuild. The symlink in
`~/.config/` updates automatically.

```bash
nixconf && nvim home-manager/dotfiles/sway/config
nixrebuild
```

### Modify zsh config (aliases, plugins, env vars)

Edit `home-manager/home.nix` → `programs.zsh` block. All the antigen stuff
(old-school plugin loading) is replaced with native HM plugins. Example:

```nix
programs.zsh = {
  shellAliases = {
    myalias = "some command";
  };
  initContent = '' … '';  # raw zsh lines injected into .zshrc
};
```

### Add a bin script

1. Drop the script into `home-manager/dotfiles/bin/`
2. Add its name to the `binScripts` list at the top of `home.nix`
3. Rebuild

### Change the look (themes, fonts, cursors)

Fonts are in `nixos/configuration.nix` → `fonts.packages` (system-wide,
available to all apps). GTK theme, cursor, and icons are in
`home-manager/home.nix` → `gtk` and `home.pointerCursor`.

### Unfree packages (Spotify, Steam, …)

Already enabled: `nixpkgs.config.allowUnfree = true` in `configuration.nix`.
Just add the package name.

### Update everything

```bash
nix flake update ~/nix-config    # fetch latest nixpkgs + home-manager revisions
nixrebuild                        # build and activate
```

If something breaks, roll back instantly:
```bash
sudo nixos-rebuild switch --rollback
```

### Collect garbage (free disk space)

```bash
sudo nix-collect-garbage -d      # delete all unused store paths
nix-collect-garbage -d           # same for user profile
# Or wait for automatic weekly GC (configured in configuration.nix)
```

### See what generations exist

```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## Nix language crash course

You'll mostly edit lists and attribute sets. Here's the minimum:

```nix
# Lists (packages)
[ pkgs.foo pkgs.bar ]       # whitespace-separated list
with pkgs; [ foo bar ]      # with pkgs; brings everything into scope

# Attribute sets (options)
{ enable = true;            # semicolons, not commas
  package = pkgs.foo;
}

# Strings
"hello"
''multi-line
  string''                  # two single quotes = indentable multi-line

# String interpolation
"${pkgs.foo}/bin/foo"       # embeds nix expression result

# Functions
name: value                 # lambda
{ config, pkgs, ... }: …    # function taking an attrset (module pattern)

# Comments
# single line
/* multi-line */
```

### Sync and read email (neomutt + mbsync + msmtp)

Declarative replacement for mutt-wizard, defined in `home-manager/email.nix`:

- `mbsync -a` — sync mail from Spacemail (IMAP `mail.spacemail.com:993`) into `~/.local/share/mail/spacemail/`
- `neomutt` — the client (sidebar + vim keys), sends via msmtp (`mail.spacemail.com:465`)

Passwords come from `pass` — store at `~/.password-store`, entry `email/philipp@thaler.fyi`
(mutt-wizard layout). To sign/encrypt mail, uncomment the `gpg` block in `email.nix`
and set your key id from `gpg --list-keys`.

## What's missing (not ported from the Arch machine)

- **Android Studio, IntelliJ, GoLand** — install manually or add as packages
- **Chromium** — add `chromium` to `home.packages` if needed
- **NVM** — `nodejs_22` from nixpkgs replaces it; `npm install -g` works with
  the prefix set to `~/.npm-global`

## Tips

- **Check what a rebuild will do** (dry-run): `nixos-rebuild dry-build --flake ~/nix-config#nixos`
- **Evaluate an option quickly**: `nix eval ~/nix-config#nixosConfigurations.nixos.config.programs.zsh.enable`
- **Find where an option is set**: read `configuration.nix` and `home.nix` — they're the only two files you need to touch normally
- **NixOS manual**: https://nixos.org/manual/nixos/stable/
- **Home Manager manual**: https://nix-community.github.io/home-manager/
- **Package search**: https://search.nixos.org/packages
- **NixOS options search**: https://search.nixos.org/options
