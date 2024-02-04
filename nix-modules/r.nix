{ fixed, pkgs, ...}:
let fixed_pkgs = fixed.legacyPackages.${pkgs.system}; in
with fixed_pkgs.rPackages;
let r_packages = [
  cluster
  clValid
  copula
  cowplot
  datasetsICR
  dbscan
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
  RecordLinkage
  reshape2
  rmarkdown
  sn
  stringdist
  stringi
  TeachingDemos
  textreuse
  tidyverse
  vcd
  xtable
];
in
{
  environment.systemPackages = with fixed_pkgs; [
    (rWrapper.override{ packages = r_packages;})
    (rstudioWrapper.override{ packages = r_packages;})
  ];
}
