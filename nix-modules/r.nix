{ pkgs, ...}: 
with pkgs.rPackages;
let r_packages = [
  cluster
  copula
  datasetsICR
  e1071
  factoextra
  fclust
  fitdistrplus
  foreign
  ggplot2
  ghyp
  KernSmooth
  labstatR
  languageserver
  MASS
  mclust
  mnormt
  reshape2
  sn
  TeachingDemos
  vcd
  xtable 
];
in
{
  environment.systemPackages = with pkgs; [
    (rWrapper.override{ packages = r_packages;})
    (rstudioWrapper.override{ packages = r_packages;})
  ];
}
