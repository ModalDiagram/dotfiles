{ config, fixed, pkgs, lib, ...}:
let fixed_pkgs = fixed.legacyPackages.${pkgs.system}; in
with fixed_pkgs.rPackages;
let r_packages = [
  cluster
  clValid
  copula
  cowplot
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
  foreign
  fpc
  gamlss
  gamlss_mx
  gclus
  geoR
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
  RecordLinkage
  reshape2
  rmarkdown
  plotly
  psych
  shinydashboard
  skimr
  sn
  stringdist
  stringi
  TeachingDemos
  textreuse
  tidyverse
  vcd
  visdat
  vtable
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
