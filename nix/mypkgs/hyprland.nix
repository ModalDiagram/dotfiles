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
    programs.hyprland = {
      enable = true;
      # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      # portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };

    environment.systemPackages = with pkgs; [
      libsForQt5.qt5.qtgraphicaleffects
      libsForQt5.qt5.qtsvg
      libsForQt5.qt5ct
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
        "gtk"
      ];
    };
    security.pam.services.swaylock = {};


    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet -r --remember-session";
          user = "greeter";
        };
      };
    };
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal"; # Without this errors will spam on screen
      # Without these bootlogs will spam on screen
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
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

      ## amdvlk is an alternative driver
      ## libGL is needed for many electron apps; mesa and libva for steam
      extraPackages = with pkgs; [ amdvlk libGL mesa libva ];
      extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
      setLdLibraryPath = true;
    };

    home-manager.users.${config.main-user} = {
      home.packages = with pkgs; [
        alacritty
        blueberry
        brightnessctl
        chromium
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
        greetd.tuigreet
        slurp # screenshot functionality
        sway-contrib.grimshot
        swaylock-effects
        udiskie
        wayland
        wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
        wofi
        xdg-utils # for opening default programs when clicking links
        xournalpp
        ydotool
      ];

      services.swayidle = {
        enable = true;
        timeouts = [
          {
            timeout = 300;
            command = "${pkgs.libnotify}/bin/notify-send -p --urgency=critical \"Turning off in 10 seconds\" > /tmp/suspend_notification_id.txt";
            resumeCommand = "${pkgs.mako}/bin/makoctl dismiss -n $(${pkgs.coreutils-full}/bin/cat /tmp/suspend_notification_id.txt)";
          }
          {
            timeout = 310;
            command = "/run/current-system/sw/bin/hyprctl dispatch dpms off eDP-1";
            resumeCommand = "/run/current-system/sw/bin/hyprctl dispatch dpms on eDP-1";
          }
          {
            timeout = 309;
            command = "export PATH=/home/sandro0198/.nix-profile/bin/:/run/current-system/sw/bin/; bash /home/sandro0198/.local/share/my_lock/my_lock.sh";
          }
        ];
        events = [
          {
            event = "before-sleep";
            command = "export PATH=/home/sandro0198/.nix-profile/bin/:/run/current-system/sw/bin/; bash /home/sandro0198/.local/share/my_lock/my_lock.sh"; }
        ];
      };

      programs.waybar = {
        enable = true;
        systemd.enable = true;
      };

      # hint Electron apps to use Wayland:
      home.sessionVariables.NIXOS_OZONE_WL = "1";
      wayland.windowManager.hyprland = {
        enable = true;
        # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

        xwayland.enable = true;

        extraConfig = "source = /data/dotfiles/conf.d/hypr/hyprland.conf";
      };
    };
  };
}
