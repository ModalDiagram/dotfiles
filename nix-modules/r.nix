{ pkgs, ...}: 
with pkgs.rPackages;
let r_packages = [
  cluster
  clValid
  copula
  cowplot
  datasetsICR
  e1071
  factoextra
  fclust
  fitdistrplus
  flexCWM
  flexclust
  foreign
  fpc
  gamlss
  gamlss_mx
  gclus
  geoR
  GGally
  ggplot2
  ghyp
  gridExtra
  hopkins
  KernSmooth
  labstatR
  languageserver
  markdown
  MASS
  mclust
  mnormt
  moments
  NbClust
  plot3D
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
