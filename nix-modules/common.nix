{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bash
    bat
    bc
    ctags
    fd
    fzf
    gcc
    gh
    glib
    gnumake
    lm_sensors
    pkg-config
    powerline-go
    pulseaudio
    ripgrep
    stow
    udev
    unzip
    vim
    wget
    zip
  ];

  # networking.wireless.networks."Vodafone-C0051203"

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
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "FiraCodeNerdFont" ];
      };
    };
  };
}
