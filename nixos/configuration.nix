{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./thinkfan.nix
  ];

  # ── Boot ──────────────────────────────────────────────────────────
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sda";
  # boot.loader.grub.useOSProber = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.systemd.enable = true;
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

  # ── User ──────────────────────────────────────────────────────────
  users.users.philipp = {
    isNormalUser = true;
    description = "philipp";
    extraGroups = [ "networkmanager" "wheel" "video" "input" "docker" ];
    shell = pkgs.zsh;
  };

  # Passwordless sudo for wheel (declarative replacement for sudoers.d hacks)
  security.sudo.wheelNeedsPassword = false;

  # ── Nix ───────────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
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
  security.pam.services.swaylock = { };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
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
    extraPackages = with pkgs; [ intel-vaapi-driver ];
  };
  services.upower.enable = true;
  services.thermald.enable = true;
  services.udev.packages = [ pkgs.brightnessctl ];

  # ── Services ──────────────────────────────────────────────────────
  services.gvfs.enable = true;
  services.openssh.enable = true;
  security.polkit.enable = true;
  programs.dconf.enable = true;
  services.gnome.gnome-keyring.enable = true;
  programs.kdeconnect.enable = true;
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
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data were taken. Don't change without reading
  # `man configuration.nix`.
  system.stateVersion = "26.05";
}
