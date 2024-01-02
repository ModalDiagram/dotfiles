{ pkgs, ... }:
let my_python_packages = ps: with ps; [
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
  pynvim
  python-lsp-ruff
  python-lsp-server
  requests
  selenium
];
in {
  home.packages = with pkgs; [
    (python311.withPackages my_python_packages)
  ];
}
