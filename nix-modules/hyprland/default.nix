{ system, inputs, config, pkgs, ... }: let
  inherit (inputs) hyprland hyprland-hy3;
in {
  imports = [ hyprland.nixosModules.default ];

  config = {
    programs.hyprland.enable = true;

    environment.systemPackages = with pkgs; [
      libsForQt5.qt5.qtgraphicaleffects
      libsForQt5.qt5.qtsvg
      libsForQt5.qt5ct
      (pkgs.callPackage ../pkgs/sddm-themes.nix {})
    ];

    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    services.flatpak.enable = true;

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      alsa.support32Bit = true;
    };
    services.dbus.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-wlr
      ];

      config.common.default = [
        "hyprland"
        "wlr"
        "gtk"
      ];
    };
    security.pam.services.swaylock = {};


    services.xserver.enable = true;
    services.xserver.videoDrivers = [ "amdgpu" ];
    services.xserver.displayManager.sddm = {
      enable = true;
      theme = "sugar-candy";
      wayland.enable = true;
    };


    services.udev.extraRules = ''
        KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
      '';
    systemd.packages = [ pkgs.ydotool ];
    systemd.user.services.ydotool.wantedBy = [ "default.target" ];
    systemd.user.services.opentabletdriver.wantedBy = [ "default.target" ];

    hardware.opengl = {
      ## radv: an open-source Vulkan driver from freedesktop
      driSupport = true;
      driSupport32Bit = true;

      ## amdvlk: an open-source Vulkan driver from AMD
      extraPackages = [ pkgs.amdvlk pkgs.rocmPackages.clr.icd ];
      extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
    };

    home-manager.users.${config.main-user} = {
      imports = [ hyprland.homeManagerModules.default ];

      home.packages = with pkgs; [
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

      wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;

        plugins = [ hyprland-hy3.packages.${system}.default  ];

        extraConfig = "source = /data/dotfiles/conf.d/hypr/hyprland.conf";
      };
    };
  };
}
