{ config, fixed, pkgs, lib, ...}:
let fixed_pkgs = fixed.legacyPackages.${pkgs.stdenv.hostPlatform.system}; in
with fixed_pkgs.rPackages;
let r_packages = [
  cluster
  clValid
  copula
  cowplot
  crossval
  cvms
  datasetsICR
  DataExplorer
  dbscan
  e1071
  factoextra
  fclust
  fitdistrplus
  flexCWM
  flexclust
  flexdashboard
  flextable
  foreign
  fpc
  gamlss
  gamlss_mx
  gbm
  gclus
  geoR
  glmnet
  GGally
  ggplot2
  ggtext
  ghyp
  gridExtra
  gt
  hopkins
  ISLR
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
  plotly
  pROC
  psych
  randomForest
  RecordLinkage
  reshape2
  rmarkdown
  ROCR
  shinydashboard
  skimr
  sn
  stringdist
  stringi
  TeachingDemos
  textreuse
  tidytext
  tidyverse
  tm
  tree
  vcd
  visdat
  vtable
  webshot2
  xtable
];
in
{
  options.mypkgs.rlang = {
    enable = lib.mkOption {
      description = "Enable r, rstudio and its packages";
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf (config.mypkgs.rlang.enable) {
    environment.systemPackages = with fixed_pkgs; [
      (rWrapper.override{ packages = r_packages;})
      (rstudioWrapper.override{ packages = r_packages;})
    ];
  };
}
