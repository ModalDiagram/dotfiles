{ pkgs, config, lib, hyprland, hy3, ... }: {
  imports =
    [
      hyprland.homeManagerModules.default
    ];

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = "source = /data/dotfiles/conf.d/hypr/hyprland.conf";
    plugins = [ hy3.packages.x86_64-linux.hy3 ];
  };

  home.packages = with pkgs; [
    (pkgs.callPackage ../nix-modules/pkgs/sddm-themes.nix {})
    alacritty
    blueberry
    brightnessctl
    chromium
    eww-wayland
    gh
    glib # gsettings
    # dracula-theme # gtk theme
    gnome3.adwaita-icon-theme  # default gnome cursors
    gnome.zenity
    gojq
    grim # screenshot functionality
    hyprpaper
    libinput-gestures
    libnotify
    libreoffice
    mako # notification system developed by swaywm maintainer
    nwg-look
    obsidian
    okular
    pavucontrol
    playerctl
    slurp # screenshot functionality
    sway-contrib.grimshot
    swaylock-effects
    swayidle
    wayland
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    wofi
    xdg-utils # for opening default programs when clicking links
    xournalpp
    ydotool
  ];
  
  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };
}
