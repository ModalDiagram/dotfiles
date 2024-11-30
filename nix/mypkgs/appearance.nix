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
  # options.mypkgs.appearance = {
  #   enable = lib.mkOption {
  #     description = "Enable theme management";
  #     type = lib.type.bool;
  #   };
  #   name = lib.mkOption {
  #     description = "Name of the theme to enable";
  #     type = lib.type.string;
  #   };
  # };

  config = lib.mkIf (config.mypkgs.theme.enable) {
    home-manager.users.${config.main-user} = let name = config.mypkgs.theme.name; in { config, ... }: {
      home.file = let config_path = "/data/dotfiles"; in {
        ".config/alacritty/theme.toml".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/alacritty/${name}/theme.toml";
        ".config/mako/".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/mako/${name}";
        ".config/waybar/".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/waybar/${name}";
        ".config/wofi/".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/wofi/${name}";
      };
    };
  };
}
