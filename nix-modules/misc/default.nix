{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bash
    bat
    bc
    ctags
    dconf
    ddcutil
    dolphin
    fd
    fzf
    gcc
    gh
    glib
    gnumake
    jq
    lm_sensors
    pkg-config
    powerline-go
    ripgrep
    stow
    udev
    unzip
    vim
    wget
    zip

    sway
    kitty
  ];

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
}
