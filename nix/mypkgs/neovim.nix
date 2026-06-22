{ config, pkgs, lib, ... }: {
  options.mypkgs.neovim = {
    enable = lib.mkOption {
      description = "Enable neovim";
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf (config.mypkgs.neovim.enable ) {
      programs.neovim = {
        enable = true;
        withPython3 = true;
      };
    home-manager.users.${config.main-user} = {
      home.packages = with pkgs; [
        gcc
        go
        gopls
        jdk
        lldb
        lua-language-server
        luarocks
        nil
        nodejs
        bash-language-server
        vscode-langservers-extracted
        php
        rust-analyzer
        shellcheck
        texlab
        typescript-language-server
        tree-sitter
      ];
    };
  };
}
