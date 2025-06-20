{ config, pkgs, lib, ... }: {
  options.mypkgs.misc = {
    enable = lib.mkOption {
      description = "Enable various common packages";
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf (config.mypkgs.misc.enable) {
    services.xserver.enable = true;
    services.desktopManager.plasma6.enable = true;

    environment.systemPackages = with pkgs; [
      xorg.xhost
      # Command line-related packages
      bash
      bat
      bc
      ctags
      dconf
      ddcutil
      fd
      fzf
      gcc
      glib
      gnumake
      jq
      powerline-go
      recode
      ripgrep
      tldr
      vim
      wget

      # System packages
      jmtpfs
      lm_sensors
      kdePackages.polkit-kde-agent-1
      pkg-config
      root
      rustup
      udev

      # Desktop environment packages
      kdePackages.dolphin
      xfce.thunar
      gedit
      imv
      mpv
      smplayer

      # Utility apps
      ferdium
      gh
      gimp
      gnome-boxes
      gparted
      kopia
      ncdu
      obsidian
      pdftk
      rclone
      signal-desktop
      spotify
      stow
      unzip
      wev
      zip
    ];

    services.openssh.enable = true;
    services.openssh.settings.X11Forwarding = true;
    services.gvfs.enable = true;
    # services.elasticsearch.enable = true;
    # virtualisation.virtualbox.host.enable = true;
    # users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
    # programs.virt-manager.enable = true;
    # virtualisation.libvirtd = {
    #   enable = true;
    #   qemu = {
    #     package = pkgs.qemu_kvm;
    #     runAsRoot = true;
    #     swtpm.enable = true;
    #     ovmf = {
    #       enable = true;
    #       packages = [(pkgs.OVMF.override {
    #         secureBoot = true;
    #         tpmSupport = true;
    #       }).fd];
    #     };
    #   };
    # };

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
        nerd-fonts.fira-mono
        nerd-fonts.iosevka-term
        fira
      ];
      fontconfig = {
        defaultFonts = {
          serif = [ "FiraSans" ];
          sansSerif = [ "FiraSans" ];
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
