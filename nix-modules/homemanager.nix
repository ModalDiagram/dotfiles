{ pkgs, config, ... }: {
  home.packages = [ ];

  home.pointerCursor = {
      name = "Qogir";
      package = pkgs.qogir-icon-theme;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = "Qogir";
      package = pkgs.qogir-icon-theme;
    };
    #iconTheme = {
    #  name = "Papirus-Dark";
    #  package = pkgs.papirus-icon-theme;
    #};
  };
  services.mako = {
    enable = true;
    backgroundColor = "#191724";
    borderRadius = 5;
    borderSize = 3;
    textColor = "#e0def4";
    extraConfig = "
[urgency=high]
layer=overlay
background-color=#e0def4
border-color=#eb6f92
text-color=#21202e

[app-name=\"spotify\"]
border-color=#1DB954";
  };

  programs.git = {
    enable = true;
    userName  = "ModalDiagram";
    userEmail = "git@sanfio.eu";
  };

  programs.vim = {
    enable = true;
    # extraConfig = builtins.readFile vim/vimrc;
    settings = {
       relativenumber = true;
       number = true;
       expandtab = true;
       shiftwidth = 2;
       tabstop = 2;
    };
  };

  home.file = {
    ".bashrc".source = config.lib.file.mkOutOfStoreSymlink ../conf.d/bashrc;
    ".profile".source = config.lib.file.mkOutOfStoreSymlink ../conf.d/profile;
    ".local/share/survey/".source = config.lib.file.mkOutOfStoreSymlink ../apps/survey;
    ".local/share/my_lock/".source = config.lib.file.mkOutOfStoreSymlink ../apps/my_lock;
    ".local/share/app_bindings/".source = config.lib.file.mkOutOfStoreSymlink ../conf.d/app_bindings;
    ".config/mimeapps.list".source = config.lib.file.mkOutOfStoreSymlink ../conf.d/xdg-open/mimeapps.list;
    ".config/libinput-gestures.conf".source = config.lib.file.mkOutOfStoreSymlink ../conf.d/libinput-gestures/libinput-gestures.conf;
    ".config/alacritty/".source = config.lib.file.mkOutOfStoreSymlink ../conf.d/alacritty/solarized;
    ".config/hypr/".source = config.lib.file.mkOutOfStoreSymlink ../conf.d/hypr;
    ".config/nvim/".source = config.lib.file.mkOutOfStoreSymlink ../conf.d/nvim;
    ".config/waybar/".source = config.lib.file.mkOutOfStoreSymlink ../conf.d/waybar;
    ".config/wofi/".source = config.lib.file.mkOutOfStoreSymlink ../conf.d/wofi;
    
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.11";
}
