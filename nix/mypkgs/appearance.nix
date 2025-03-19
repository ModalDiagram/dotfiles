{ config, lib, ... }: {
  options.mypkgs.theme = {
    enable = lib.mkOption {
      description = "enable theme management";
      type = lib.types.bool;
      default = false;
    };
    name = lib.mkOption {
      description = "name of the theme to enable";
      type = lib.types.str;
      default = "";
    };
  };

  config = lib.mkIf (config.mypkgs.theme.enable) {
    home-manager.users.${config.main-user} = let name = config.mypkgs.theme.name; in { config, ... }: {
      home.file = let config_path = "/data/dotfiles"; in {
        ".config/alacritty/theme.toml".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/nix/themes/${name}/alacritty/theme.toml";
        ".config/mako/".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/nix/themes/${name}/mako/";
        ".config/waybar/".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/nix/themes/${name}/waybar/";
        ".config/wofi/".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/nix/themes/${name}/wofi/";
        ".config/hypr/theme.conf".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/nix/themes/${name}/hypr/theme.conf";
        ".config/hypr/hyprpaper.conf".source    = config.lib.file.mkOutOfStoreSymlink "${config_path}/nix/themes/${name}/hypr/hyprpaper.conf";
      };
    };
  };
}
