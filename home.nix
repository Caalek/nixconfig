{ pkgs, ... }:

{
  home.username = "user";
  home.homeDirectory = "/home/user";
  home.stateVersion = "25.11";

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

  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
    extensions = with pkgs.vscode-extensions; [
      ms-azuretools.vscode-docker ms-python.python hashicorp.terraform
      ms-vscode-remote.remote-containers
    ];
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
    gtk3.extraConfig = {
      "gtk-theme-name" = "adw-gtk3";
    };
    gtk4.extraConfig = {
      "gtk-theme-name" = "adw-gtk3-dark";
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3";
      monospace-font-name = "JetBrainsMono Nerd Font 11";
    };
  };

  home.sessionVariables = {
    GTK_THEME = "adw-gtk3";
  };

  home.packages = with pkgs; [
    ansible awscli2 azure-cli
    btop bun cargo chromium curl discord element-desktop
    fastfetch fzf git gnome-extension-manager
    go google-cloud-sdk hcloud htop k9s
    kubectl kubernetes-helm libreoffice-fresh localsend mediawriter
    mpv neovim nextcloud-client nodejs obsidian obs-studio
    openconnect pciutils planify pnpm python313 python313Packages.pip
    qbittorrent rustc rustdesk signal-desktop solaar teams-for-linux
    telegram-desktop terraform usbutils
    snicat sshpass uv vim virt-manager wget wireguard-tools yarn zellij
    opencode
  ];
}
