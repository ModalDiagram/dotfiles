{ config, pkgs, lib, ... }: let
my_python_packages = ps: with ps; [
  beautifulsoup4
  debugpy
  google-cloud-firestore
  google-cloud-storage
  lxml
  jedi-language-server
  jupyterlab-lsp
  notebook
  numpy
  matplotlib
  pandas
  plotly
  pynvim
  python-lsp-ruff
  python-lsp-server
  requests
  selenium
  python-telegram-bot
];
in {
  options.mypkgs.python = {
    enable = lib.mkOption {
      description = "Enable python common packages";
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf (config.mypkgs.python.enable) {
    environment.systemPackages = with pkgs; [
      (python311.withPackages my_python_packages)
    ];
  };
}
