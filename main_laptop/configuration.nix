# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../nix-modules/common.nix
      #../nix-modules/hyprland.nix
      ../nix-modules/r.nix
      ../nix-modules/sql.nix
      ../nix-modules/tex.nix
    ];


  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 30;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = ["amdgpu.gpu_recovery=1"];

  security.pam.services.swaylock = {};
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.wireless.iwd = {
    enable = true;
    settings = {
      Settings = {
        AutoConnect = true;
      };
    };
  };
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.hostName = "nixos"; # Define your hostname.
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
  networking.firewall.enable = true;
  networking.firewall.extraCommands = ''
    iptables -A INPUT -p tcp -i wlan0 --dport 5000:5002 -j ACCEPT
    iptables -A INPUT -p tcp -i tailscale0 --dport 5000:5002 -j ACCEPT
  '';

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "it";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "it";

  hardware.opengl = {
    ## radv: an open-source Vulkan driver from freedesktop
    driSupport = true;
    driSupport32Bit = true;

    ## amdvlk: an open-source Vulkan driver from AMD
    extraPackages = [ pkgs.amdvlk ];
    extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
  };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sandro0198 = {
    isNormalUser = true;
    description = "Sandro";
    extraGroups = [ "networkmanager" "wheel" "input" "uinput" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    XCURSOR_SIZE = "48";
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    rustup
    # blueberry
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtsvg
    libsForQt5.qt5ct
    (pkgs.callPackage ../nix-modules/pkgs/sddm-themes.nix {})
    ydotool
  ];

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  services.tailscale.enable = true;
  systemd.services.tailscaled.wantedBy = lib.mkForce [];

  services.xserver.enable = true;
  services.xserver.displayManager.sddm = {
    enable = true;
    theme = "sugar-candy";
    wayland.enable = true;
  };
  services.xserver.displayManager.session = [
    {
      manage = "desktop";
      name = "Hyprland";
      type = "wayland";
      start = ''
        Hyprland
        waitPID=$!
      '';
    }
  ];

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
    config.common.default = "*";
    wlr.enable = false;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
    '';
  systemd.packages = [ pkgs.ydotool ];
  systemd.user.services.ydotool.wantedBy = [ "default.target" ];
  systemd.user.services.opentabletdriver.wantedBy = [ "default.target" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
