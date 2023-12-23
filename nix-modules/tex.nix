{ pkgs, ...}: 
{
  environment.systemPackages = with pkgs; [
    (texlive.combine {
      inherit (pkgs.texlive) scheme-medium
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
