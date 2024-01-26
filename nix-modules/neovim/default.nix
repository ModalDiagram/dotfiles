{ config, pkgs, ... }: {
  config = {
    home-manager.users.${config.main-user} = {
      home.packages = with pkgs; [
        neovim
        go
        gopls
        jdk17
        lua-language-server
        luarocks
        nil
        nodejs
        nodePackages.bash-language-server
        php
        rust-analyzer
        shellcheck
        texlab
        tree-sitter
      ];
    };
  };
}
