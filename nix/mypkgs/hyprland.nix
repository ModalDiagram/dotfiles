{ config, pkgs, lib, inputs, ... }: {
  imports = [ inputs.hyprland.nixosModules.default ];

  options.mypkgs.hyprland = {
    enable = lib.mkOption {
      description = "Enable hyprland";
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (config.mypkgs.hyprland.enable) {

    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

    programs.hyprland.enable = true;

    environment.systemPackages = with pkgs; [
      libsForQt5.qt5.qtgraphicaleffects
      libsForQt5.qt5.qtsvg
      libsForQt5.qt5ct
      (pkgs.callPackage ./build/sddm-themes.nix {})
    ];

    services.flatpak.enable = true;

    services.udisks2.enable = true;

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
      ];

      config.common.default = [
        "hyprland"
        "wlr"
        "gtk"
      ];
    };
    security.pam.services.swaylock = {};


    services.xserver.enable = true;
    services.xserver.displayManager.sddm = {
      enable = true;
      theme = "sugar-candy";
      wayland.enable = true;
    };

    # rule 1: add access to uinput for users of group uinput
    # rule 2: add access to touchpad for users of group uinput (for gestures)
    services.udev.extraRules = ''
        KERNEL=="uinput", GROUP="uinput", MODE="0660"
        KERNEL=="event[0-9]*", SUBSYSTEM=="input", ATTRS{name}=="ELAN06FA:00 04F3:3280 Touchpad", GROUP="uinput"
      '';
        # KERNEL=="event[0-9]*", SUBSYSTEM=="input", ATTRS{name}=="ELAN06FA:00 04F3:3280 Touchpad", GROUP="uinput", OPTIONS+="static_node=uinput"
    # systemd.packages = [ pkgs.ydotool ];
    # systemd.user.services.ydotool.wantedBy = [ "default.target" ];
    systemd.user.services.opentabletdriver.wantedBy = [ "default.target" ];


    hardware.opengl = {
      enable = true;
      ## radv: an open-source Vulkan driver from freedesktop
      driSupport = true;
      driSupport32Bit = true;

      ## amdvlk: an open-source Vulkan driver from AMD
      extraPackages = with pkgs; [ amdvlk rocmPackages.clr.icd mesa.drivers libGL ];
      extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
      setLdLibraryPath = true;
    };

    home-manager.users.${config.main-user} = {
      imports = [
        inputs.hyprland.homeManagerModules.default
      ];

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
        gsimplecal
        hyprpaper
        libinput-gestures
        libnotify
        libreoffice
        mako # notification system developed by swaywm maintainer
        nwg-look
        okular
        pavucontrol
        playerctl
        slurp # screenshot functionality
        sway-contrib.grimshot
        swaylock-effects
        swayidle
        udiskie
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

        extraConfig = "source = /data/dotfiles/conf.d/hypr/hyprland.conf";
      };
    };
  };
}
