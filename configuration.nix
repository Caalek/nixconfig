{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
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
  services.displayManager.gdm.wayland = true;
  services.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    baobab cheese epiphany geary gnome-characters gnome-clocks
    gnome-console gnome-connections gnome-contacts gnome-logs
    gnome-maps gnome-music gnome-photos gnome-tour gnome-weather
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
  programs.firefox = {
    enable = true;
    policies = {
      Preferences = {
        "sidebar.revamp" = { Value = true; Status = "locked"; };
        "sidebar.verticalTabs" = { Value = true; Status = "locked"; };
      };
    };
  };
  programs.dconf.enable = true;
  programs.nix-ld.enable = true;

  qt.enable = true;
  qt.platformTheme = "gnome";
  qt.style = "adwaita";

  environment.systemPackages = with pkgs; [
    adw-gtk3
    gnomeExtensions.appindicator
    gnomeExtensions.syncthing-indicator
    gnomeExtensions.tiling-shell
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

  system.stateVersion = "25.11";
}
