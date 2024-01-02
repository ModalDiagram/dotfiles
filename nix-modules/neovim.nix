{ pkgs, ... }: {
  home.packages = with pkgs; [
    neovim
    go
    gopls
    jdk17
    julia
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

}
