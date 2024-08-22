{ inputs, pkgs, config, ... }: let
  gtk-theme = "adw-gtk3-dark";
  nerdfonts = (pkgs.nerdfonts.override {
    fonts = [
      "Ubuntu"
      "UbuntuMono"
      "CascadiaCode"
      "FantasqueSansMono"
      "JetBrainsMono"
      "FiraCode"
      "Mononoki"
      "SpaceMono"
    ];
  });
  google-fonts = (pkgs.google-fonts.override {
    fonts = [
      # Sans
      "Gabarito" "Lexend"
      # Serif
      "Chakra Petch" "Crimson Text"
    ];
  });

  cursor-theme = "Bibata-Modern-Classic";
  cursor-package = pkgs.bibata-cursors;
in
{
  home-manager.users.${config.main-user} = {
    imports = [
      inputs.ags.homeManagerModules.default
    ];

    home.packages = with pkgs; [
      adwaita-qt6
      adw-gtk3
      material-symbols
      nerdfonts
      noto-fonts
      noto-fonts-cjk-sans
      google-fonts
      moreWaita
      bibata-cursors
      ollama
      pywal
      sassc
      (python311.withPackages (p: [
        p.material-color-utilities
        p.pywayland
      ]))
    ];

    sessionVariables = {
      XCURSOR_THEME = cursor-theme;
      XCURSOR_SIZE = "24";
    };
    pointerCursor = {
      package = cursor-package;
      name = cursor-theme;
      size = 24;
      gtk.enable = true;
    };

    file = {
      ".local/share/fonts" = {
        recursive = true;
        source = "${nerdfonts}/share/fonts/truetype/NerdFonts";
      };
      ".fonts" = {
        recursive = true;
        source = "${nerdfonts}/share/fonts/truetype/NerdFonts";
      };
    };

  gtk = {
    enable = true;
    font.name = "Rubik";
    theme.name = gtk-theme;
    cursorTheme = {
      name = cursor-theme;
      package = cursor-package;
    };
    gtk3.extraCss = ''
      headerbar, .titlebar,
      .csd:not(.popup):not(tooltip):not(messagedialog) decoration{
        border-radius: 0;
      }
    '';
  };

  qt = {
    enable = true;
    platformTheme = "kde";
  };

    programs.ags = {
      enable = true;
      configDir = null; # if ags dir is managed by home-manager, it'll end up being read-only. not too cool.
      # configDir = ./.config/ags;

      extraPackages = with pkgs; [
        gtksourceview
        gtksourceview4
        ollama
        python311Packages.material-color-utilities
        python311Packages.pywayland
        pywal
        sassc
        webkitgtk
        webp-pixbuf-loader
        ydotool
      ];
    };
  };
}
