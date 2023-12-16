{ pkgs, ...}: 
{
  environment.systemPackages = with pkgs; [
    (texlive.combine {
      inherit (pkgs.texlive) scheme-medium
        framed
        xcolor
        #(setq org-latex-compiler "lualatex")
        #(setq org-preview-latex-default-process 'dvisvgm)
    ;})
  ];
}
