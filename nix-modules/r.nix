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
  flexCWM
  foreign
  gamlss
  gclus
  geoR
  GGally
  ggplot2
  ghyp
  gridExtra
  KernSmooth
  labstatR
  languageserver
  markdown
  MASS
  mclust
  mnormt
  moments
  NbClust
  reshape2
  rmarkdown
  sn
  TeachingDemos
  tidyverse
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
