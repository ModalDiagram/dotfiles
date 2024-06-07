{ config, pkgs, lib, ... }: {
  options.mypkgs.misc = {
    enable = lib.mkOption {
      description = "Enable various common packages";
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf (config.mypkgs.misc.enable) {
    environment.systemPackages = with pkgs; [
      bash
      bat
      bc
      ctags
      dconf
      ddcutil
      dolphin
      ferdium
      fd
      fzf
      gcc
      gedit
      gh
      gimp
      glib
      gnumake
      gparted
      imv
      jq
      jmtpfs
      lm_sensors
      mpv
      obsidian
      pdftk
      pkg-config
      polkit-kde-agent
      powerline-go
      ripgrep
      rustup
      ncdu
      smplayer
      spotify
      stow
      tldr
      udev
      unzip
      vim
      wget
      wev
      zip

      awscli2
      google-cloud-sdk
      firebase-tools
      spice-vdagent
    ];

    # virtualisation.virtualbox.host.enable = true;
    # users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];

    # virtualisation.docker.enable = true;
    # virtualisation.docker.rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
    services.tailscale.enable = true;
    systemd.services.tailscaled.wantedBy = lib.mkForce [];

    systemd.timers."subitoTracker" = {
      wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "60m";
          OnUnitActiveSec = "60m";
          Unit = "subitoTracker.service";
        };
    };

    systemd.services."subitoTracker" = let python = pkgs.python311.withPackages (ps: with ps; [ requests python-telegram-bot beautifulsoup4 ]);
    in {
      script = ''
        ${python}/bin/python /home/sandro0198/projects/python/subitoTracker/src/main.py > /tmp/log1.txt
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "${config.main-user}";
      };
    };

    services.logind.extraConfig = ''
      # don’t shutdown when power button is short-pressed
      HandlePowerKey=suspend
    '';
    swapDevices = [ {
      device = "/var/lib/swapfile";
      size = 4*1024;
    } ];

    programs.git.enable = true;
    programs.firefox.enable = true;
    programs.steam = {
      enable = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libkrb5
          keyutils
        ];
      };
    };
    programs.steam.gamescopeSession.enable = true;

    hardware.opentabletdriver.enable = true;
    security.polkit.enable = true;

    fonts = {
      packages = with pkgs; [
        (nerdfonts.override { fonts = [ "FiraCode" "IosevkaTerm" ]; })
      ];
      fontconfig = {
        defaultFonts = {
          monospace = [ "IosevkaTermNerdFont" ];
        };
      };
    };

    home-manager.users.${config.main-user} = {
      home.pointerCursor = {
          name = "Qogir";
          package = pkgs.qogir-icon-theme;
      };

      gtk = {
        enable = true;
        cursorTheme = {
          name = "Qogir";
          package = pkgs.qogir-icon-theme;
        };
      };

      programs.git = {
        enable = true;
        userName  = "ModalDiagram";
        userEmail = "git@sanfio.eu";
      };

      programs.vim = {
        enable = true;
        # extraConfig = builtins.readFile vim/vimrc;
        settings = {
           relativenumber = true;
           number = true;
           expandtab = true;
           shiftwidth = 2;
           tabstop = 2;
        };
      };
    };
  };
}
