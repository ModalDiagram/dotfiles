{ fixed, pkgs, ...}: 
let fixed_pkgs = fixed.legacyPackages.${pkgs.system}; in
{
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
        #(setq org-latex-compiler "lualatex")
        #(setq org-preview-latex-default-process 'dvisvgm)
    ;})
  ];
}
