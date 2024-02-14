{ pkgs, ... }: let
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
];
in {
  environment.systemPackages = with pkgs; [
    (python311.withPackages my_python_packages)
  ];
}
