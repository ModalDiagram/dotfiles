{ config, fixed, pkgs, lib, ...}:
let fixed_pkgs = fixed.legacyPackages.${pkgs.system}; in
{
  options.mypkgs.tex = {
    enable = lib.mkOption {
      description = "Enable common tex packages";
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf (config.mypkgs.tex.enable) {
    environment.systemPackages = with fixed_pkgs; [
      pandoc
      (texlive.combine {
        inherit (fixed_pkgs.texlive) scheme-medium
          adjustbox
          enumitem
          framed
          xcolor
          tcolorbox
          environ
          pdfcol
          upquote
          fancyvrb
          grffile
          titling
          soul
          multirow
          wrapfig
          tabu
          threeparttable
          threeparttablex
          makecell
          #(setq org-latex-compiler "lualatex")
          #(setq org-preview-latex-default-process 'dvisvgm)
      ;})
    ];
  };
}
