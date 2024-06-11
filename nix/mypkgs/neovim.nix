{ config, pkgs, lib, ... }: {
  options.mypkgs.neovim = {
    enable = lib.mkOption {
      description = "Enable neovim";
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf (config.mypkgs.neovim.enable ) {
    home-manager.users.${config.main-user} = {
      home.packages = with pkgs; [
        neovim
        go
        gopls
        jdk17
        clang-tools_17
        lldb
        lua-language-server
        luarocks
        nil
        nodejs
        nodePackages.bash-language-server
        vscode-langservers-extracted
        php
        rust-analyzer
        shellcheck
        texlab
        tree-sitter
      ];
    };
  };
}
