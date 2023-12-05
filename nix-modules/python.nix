{ pkgs, ... }:
let my_python_packages = ps: with ps; [
  beautifulsoup4
  notebook
  numpy
  pandas
  requests
  selenium
];
in {
  environment.systemPackages = with pkgs; [
    (python311.withPackages my_python_packages)
  ];
}
