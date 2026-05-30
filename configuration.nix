{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "btrfs" ];
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openconnect
    networkmanager-vpnc
  ];
  networking.wireguard.enable = true;

  services.openssh.enable = true;
  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8"; LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8"; LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8"; LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8"; LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    baobab cheese epiphany geary gnome-characters gnome-clocks
    gnome-console gnome-connections gnome-contacts gnome-logs
    gnome-maps gnome-music gnome-photos gnome-software gnome-tour gnome-weather
    loupe rhythmbox simple-scan snapshot totem
  ];

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.epson-escpr ];
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = { enable = true; alsa.enable = true; alsa.support32Bit = true; pulse.enable = true; };
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;
  services.syncthing = {
    enable = true;
    user = "user";
    dataDir = "/home/user";
    configDir = "/home/user/.config/syncthing";
  };
  services.flatpak.enable = true;

  systemd.services.flatpak-add-flathub = {
    description = "Add Flathub remote";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    script = ''
      ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
    serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
  };

  security.sudo.wheelNeedsPassword = false;
  security.sudo.extraConfig = "%wheel ALL=(ALL) NOPASSWD: ALL";
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.libvirt.unix.manage" && subject.user == "user")
        return polkit.Result.YES;
    });
  '';

  fonts.packages = with pkgs; [
    liberation_ttf
    carlito
    caladea
    noto-fonts
    noto-fonts-color-emoji
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];
  fonts.fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];

  programs.fish.enable = true;
  programs.git = {
    enable = true;
    config = {
      safe.directory = [ "/etc/nixos" "/home/user/.config/nix" ];
    };
  };
  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      SearchEngines = {
        Default = "DuckDuckGo";
        PreventInstalls = false;
      };
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          toolbar_pin = "never_pinned";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          toolbar_pin = "force_pinned";
        };
        "myallychou@gmail.com" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-recommended-videos/latest.xpi";
          toolbar_pin = "never_pinned";
        };
      };
      Preferences = {
        "sidebar.revamp" = { Value = true; Status = "locked"; };
        "sidebar.verticalTabs" = { Value = true; Status = "locked"; };
        "browser.ml.enable" = { Value = false; Status = "locked"; };
        "browser.ml.chat.enabled" = { Value = false; Status = "locked"; };
        "browser.newtabpage.activity-stream.showSponsored" = { Value = false; Status = "locked"; };
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = { Value = false; Status = "locked"; };
        "browser.newtabpage.activity-stream.feeds.section.topstories" = { Value = false; Status = "locked"; };
        "browser.newtabpage.activity-stream.feeds.snippets" = { Value = false; Status = "locked"; };
        "browser.urlbar.suggest.sponsored" = { Value = false; Status = "locked"; };
        "browser.urlbar.quicksuggest.sponsored" = { Value = false; Status = "locked"; };
      };
    };
  };
  programs.dconf.enable = true;
  programs.wireshark.enable = true;
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      zstd
      openssl
      curl
      util-linux
      glib
      libGL
      alsa-lib
      libpulseaudio
      sqlite
      xz
      bzip2
      libffi
      ncurses
      readline
      gmp
      libcap
      expat
      libpng
      freetype
      fontconfig
      dbus
    ];
  };

  qt.enable = true;
  qt.platformTheme = "gnome";
  qt.style = "adwaita-dark";

  environment.systemPackages = with pkgs; [
    adw-gtk3
    gcc
    git
    gnomeExtensions.appindicator
    gnomeExtensions.syncthing-indicator
    gnomeExtensions.tiling-shell
    gdu
    htop
    mcp-nixos
    psmisc
    snicat
    vim
  ];

  users.users.user = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "user";
    extraGroups = [ "networkmanager" "wheel" "wireshark" "libvirtd" "docker" "adbusers" ];
  };

  nixpkgs.config.allowUnfree = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.prime.offload.enable = true;
  hardware.nvidia.open = true;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
  nix.settings.keep-outputs = false;
  nix.settings.keep-derivations = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.autoUpgrade = {
    enable = true;
    flake = "/home/user/.config/nix";
    flags = [
      "--print-build-logs"
      "--commit-lock-file"
    ];
    dates = "0/6:00";
    randomizedDelaySec = "15min";
  };

  systemd.services.nixos-upgrade.environment = {
    GIT_AUTHOR_NAME = "NixOS Auto-upgrade";
    GIT_AUTHOR_EMAIL = "root@nixos";
    GIT_COMMITTER_NAME = "NixOS Auto-upgrade";
    GIT_COMMITTER_EMAIL = "root@nixos";
  };

  system.stateVersion = "25.11";
}
