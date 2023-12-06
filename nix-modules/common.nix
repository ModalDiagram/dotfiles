{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bash
    bc
    fd
    fzf
    gcc
    gh
    glib
    gnumake
    pkg-config
    powerline-go
    pulseaudio
    ripgrep
    stow
    udev
    unzip
    vim
    wget
  ];

  programs.git.enable = true;
  programs.firefox.enable = true;
  hardware.opentabletdriver.enable = true;
  # security.polkit.enable = true;

  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "FiraCodeNerdFont" ];
      };
    };
  };
}
