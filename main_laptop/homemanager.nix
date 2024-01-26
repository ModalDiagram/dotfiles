{ pkgs, config, ... }: {
  home.file = let config_path = "/data/dotfiles"; in {
    ".bashrc".source                        = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/bashrc";
    ".profile".source                       = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/profile";
    ".local/share/survey/".source           = config.lib.file.mkOutOfStoreSymlink "${config_path}/apps/survey";
    ".local/share/my_lock/".source          = config.lib.file.mkOutOfStoreSymlink "${config_path}/apps/my_lock";
    ".local/share/app_bindings/".source     = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/app_bindings";
    ".config/mimeapps.list".source          = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/xdg-open/mimeapps.list";
    ".config/libinput-gestures.conf".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/libinput-gestures/libinput-gestures.conf";
    ".config/alacritty/".source             = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/alacritty/solarized";
    ".config/hypr/hyprpaper.conf".source    = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/hypr/hyprpaper.conf";
    ".config/nvim/".source                  = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/nvim";
    ".config/mako/".source                  = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/mako";
    ".config/waybar/".source                = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/waybar";
    ".config/wireplumber/".source           = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/wireplumber";
    ".config/wofi/".source                  = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/wofi";
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.11";
}
