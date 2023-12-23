{ pkgs, ... }:
let my_python_packages = ps: with ps; [
  beautifulsoup4
  debugpy
  google-cloud-firestore
  google-cloud-storage
  jupyterlab-lsp
  notebook
  numpy
  matplotlib
  pandas
  requests
  selenium
];
in {
  environment.systemPackages = with pkgs; [
    (python311.withPackages my_python_packages)
  ];
}
