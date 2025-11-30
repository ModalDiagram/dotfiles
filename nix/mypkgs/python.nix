{ config, pkgs, lib, ... }: let
my_python_packages = ps: with ps; [
  beautifulsoup4
  boto3
  debugpy
  imbalanced-learn
  lxml
  jedi-language-server
  jupyterlab-lsp
  keras
  notebook
  numpy
  matplotlib
  opencv4
  pandas
  plotly
  pydot
  pynvim
  # python-lsp-ruff
  # python-lsp-server
  requests
  seaborn
  scikit-learn
  scipy
  selenium
  tensorflow
  torch
  torchvision
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
      (python312.withPackages my_python_packages)
    ];
  };
}
