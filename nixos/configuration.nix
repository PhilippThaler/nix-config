{
  pkgs,
  lib,
  inputs,
  ...
}: {
  nixpkgs.overlays = [
    inputs.nur.overlays.default
  ];

  imports = [
    ./hardware-configuration.nix
    ./thinkfan.nix
    ./btrbk.nix
    ./agenix.nix
  ];

  # ── Boot ──────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    sortKey = "lanza";
  };

  boot.kernelParams = ["psmouse.synaptics_intertouch=0"]; # touchpad: flaky RMI4/SMBus probe kills the PS/2 pointer device

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.tpm2.enable = true;
  boot.resumeDevice = "/dev/mapper/luks-24967593-22f2-49cd-8aee-1d03c77a9c05";

  # ── Networking ────────────────────────────────────────────────────
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # ── Locale / keymap ───────────────────────────────────────────────
  time.timeZone = "Europe/Vienna";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };
  console.keyMap = "de";
  services.xserver.xkb = {
    layout = "de";
    variant = "deadgraveacute";
  };

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # ── User ──────────────────────────────────────────────────────────
  users.users.philipp = {
    isNormalUser = true;
    description = "philipp";
    extraGroups = ["networkmanager" "wheel" "video" "input" "docker"];
    shell = pkgs.zsh;
  };

  security.sudo.wheelNeedsPassword = false;

  # ── Nix ───────────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # ── Shell ─────────────────────────────────────────────────────────
  programs.zsh.enable = true;

  # ── Sway (swayfx) + Wayland stack ─────────────────────────────────
  programs.sway = {
    enable = true;
    package = pkgs.swayfx;
    wrapperFeatures.gtk = true;
  };
  security.pam.services.swaylock = {};
  security.pam.services.login = {
    gnupg = {
      enable = true;
      storeOnly = true;
      noAutostart = true;
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  # Login greeter (starts sway)
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd sway";
      user = "greeter";
    };
  };

  # ── Audio (PipeWire) ──────────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # ── Bluetooth ─────────────────────────────────────────────────────
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # ── Printing (driverless/AirPrint via Avahi) ──────────────────────
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # ── Hardware helpers ──────────────────────────────────────────────
  # GPU drivers (not enabled by default without xserver!) — required for sway
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [intel-vaapi-driver intel-media-driver]; # Kaby Lake (X1 Carbon 5th): iHD for full HEVC decode
  };
  services.udev.packages = [pkgs.brightnessctl];
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "auto";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };
  services.upower = {
    enable = true;
    usePercentageForPolicy = true;
    percentageAction = 5;
    criticalPowerAction = "Hibernate";
  };

  # ── Services ──────────────────────────────────────────────────────
  services.gvfs.enable = true;
  services.fwupd.enable = true;
  services.openssh.enable = true;
  services.gnome.gnome-keyring.enable = true;
  # gcr-ssh-agent competes with gpg-agent-as-ssh-agent for SSH_AUTH_SOCK; disable it.
  services.gnome.gcr-ssh-agent.enable = false;
  security.polkit.enable = true;
  # let the fwupd-check user timer refresh LVFS metadata without an interactive prompt
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.user == "philipp" && action.id == "org.freedesktop.fwupd.refresh-remote") {
        return polkit.Result.YES;
      }
    });
  '';
  programs.dconf.enable = true;
  virtualisation.docker.enable = true;

  # ── Fonts ─────────────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    dejavu_fonts
    font-awesome
    nerd-fonts.inconsolata
    nerd-fonts.inconsolata-lgc
    nerd-fonts.iosevka
    nerd-fonts.symbols-only
  ];

  # ── System packages (system-wide tools only; user apps live in home-manager) ──
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    htop
    pciutils
    usbutils
    psmisc
    procps
    file
    sbctl
    age # runtime dep for the agenix CLI + decrypting
    jq # runtime dep for the agenix CLI
    inputs.agenix.packages.${pkgs.system}.default
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data were taken. Don't change without reading
  # `man configuration.nix`.
  system.stateVersion = "26.05";
}
