{ pkgs, config, ... }:

{
  home.username = "user";
  home.homeDirectory = "/home/user";
  home.stateVersion = "25.11";
  home.enableNixpkgsReleaseCheck = false;

  xdg.configFile."fish/conf.d/00-hush.fish".text = "set -g fish_greeting \"\"\n";
  xdg.configFile."fish/conf.d/99-fzf.fish".text = "fzf --fish | source\n";

  programs.direnv.enable = true;

  programs.alacritty = {
    enable = true;
    settings = {
      font.size = 11;
      font.normal.family = "JetBrainsMono Nerd Font";
      font.bold.family = "JetBrainsMono Nerd Font";
      font.italic.family = "JetBrainsMono Nerd Font";
      font.bold_italic.family = "JetBrainsMono Nerd Font";
    };
  };
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3";
      package = pkgs.adw-gtk3;
    };
    gtk3 = {
      theme = config.gtk.theme;
      extraConfig = {
        "gtk-theme-name" = "adw-gtk3";
      };
    };
    gtk4 = {
      theme = config.gtk.theme;
      extraConfig = {
        "gtk-theme-name" = "adw-gtk3-dark";
      };
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3";
      monospace-font-name = "JetBrainsMono Nerd Font 11";
    };
    "org/gnome/shell" = {
      enabled-extensions = [ "tilingshell@ferrarodomenico.com" "syncthing@gnome.2nv2u.com" ];
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "Alacritty.desktop"
        "firefox.desktop"
        "discord.desktop"
        "obsidian.desktop"
        "signal-desktop.desktop"
        "io.github.alainm23.planify.desktop"
        "org.gnome.Calendar.desktop"
        "thunderbird.desktop"
      ];
    };
  };

  home.sessionVariables = {
    GTK_THEME = "adw-gtk3";
  };

  home.packages = with pkgs; [
    android-studio ansible awscli2 azure-cli
    btop bun burpsuite cargo chromium curl discord element-desktop
    fastfetch fzf git gnome-extension-manager
    go google-cloud-sdk hcloud htop k9s
    kubectl kubectx kubernetes-helm libreoffice-fresh localsend mariadb mediawriter
    mpv neovim nextcloud-client nodejs obsidian obs-studio onlyoffice-desktopeditors
    openconnect pciutils planify pnpm postgresql prismlauncher python313 python313Packages.pip
    qbittorrent rustc signal-desktop solaar teams-for-linux
    telegram-desktop usbutils
    snicat sshpass talosctl terraform-bin uv vim virt-manager vscode wget wireguard-tools yarn yazi zellij
    opencode
  ];

  programs.vscode = {
    enable = true;
    profiles.default = {
      userSettings = {
        "telemetry.telemetryLevel" = "off";
        "telemetry.enableCrashReporter" = false;
        "telemetry.enableTelemetry" = false;
        "update.mode" = "none";
        "update.showReleaseNotes" = false;
        "extensions.autoCheckUpdates" = false;
        "extensions.autoUpdate" = false;
        "workbench.enableExperiments" = false;
        "workbench.settings.enableNaturalLanguageSearch" = false;
        "editor.fontFamily" = "\"JetBrainsMono Nerd Font\"";
        "editor.fontSize" = 15;
        "workbench.colorTheme" = "Default Dark Modern";
      };
      extensions = with pkgs.vscode-extensions; [
        ms-azuretools.vscode-docker
        ms-python.python
        hashicorp.terraform
        ms-kubernetes-tools.vscode-kubernetes-tools
      ];
    };
  };
}
