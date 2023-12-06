{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    alacritty
    brightnessctl
    chromium
    eww-wayland
    gh
    glib # gsettings
    # dracula-theme # gtk theme
    gnome3.adwaita-icon-theme  # default gnome cursors
    gojq
    grim # screenshot functionality
    libinput-gestures
    libnotify
    libreoffice
    mako # notification system developed by swaywm maintainer
    nwg-look
    okular
    playerctl
    slurp # screenshot functionality
    sway-contrib.grimshot
    swaylock
    swayidle
    wayland
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    wofi
    xdg-utils # for opening default programs when clicking links
    ydotool
    gnome.zenity
  ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };  
  programs.waybar.enable = true;
  services.flatpak.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    alsa.support32Bit = true;
  };
  services.dbus.enable = true;
  security.pam.services.swaylock = {};
  xdg.portal = {
    enable = true;
    wlr.enable = false;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  networking.networkmanager.enable = true;

  # ydotool
  services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
    '';
  systemd.packages = [ pkgs.ydotool ];
  systemd.user.services.ydotool.wantedBy = [ "default.target" ];
  # systemd.user.services.libinput-gestures.wantedBy = [ "default.target" ];

}
