{ pkgs, ... }: {
  home.packages = with pkgs; [
    neovim
    (python3.withPackages(ps: with ps; [
      debugpy
      jedi-language-server
      pynvim
      python-lsp-ruff
      python-lsp-server
    ]))
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
