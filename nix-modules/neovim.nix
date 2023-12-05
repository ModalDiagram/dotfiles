{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    neovim
    (python3.withPackages(ps: with ps; [
      debugpy
      pynvim
      python-lsp-ruff
      python-lsp-server
    ]))
    go
    php
    jdk17
    julia
    nodejs
    luarocks
    lua-language-server
    tree-sitter
    rust-analyzer
    shellcheck
    nodePackages.bash-language-server
    nil
  ];

}
