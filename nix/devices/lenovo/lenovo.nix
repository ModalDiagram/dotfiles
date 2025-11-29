{ config, lib, pkgs, modulesPath, inputs, ... }: {
  system.stateVersion = "23.11";
  networking.hostName = "lenovo";
  # networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  # system.nssDatabases.hosts = [ "files" "mymachines" "dns" "myhostname" ];

  environment.systemPackages = [
    pkgs.wireguard-tools
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default # beta
  ];
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.11.0.2/24" ]; # The IP address for the server on the VPN
      privateKeyFile = "/run/secrets/lenovo_private_wireguard";
      peers = [
        {
          publicKey = "LQ2I1riwAsVnhfYdoUCJmuA+151Xf8BmoD360B8KGG0=";
          allowedIPs = [ "10.10.0.125/32" ]; # The IP range for the VPN
          endpoint = "www.sanfio.eu:51820"; # The server's public IP address and port
          persistentKeepalive = 25;
        }
      ];
    };
  };
  systemd.services."wireguard-wg0".wantedBy = lib.mkForce [ ];

  # Ensure the WireGuard module is enabled
  networking.firewall.allowedTCPPorts = [ 22 25565 ];

  # Settings needed for flakes
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usbhid" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "amdgpu" "i2c-dev" ];
  boot.extraModulePackages = [ ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 15;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # services.tlp.enable = true;

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  # Needed to modify the brightness of external monitors with i2c-dev
  services.udev.extraRules = ''
        KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
  '';

  # Allow unfree packages and some insecure
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/52d0cfae-30c2-4530-a31c-e5563dc518e3";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3AB4-6B6A";
      fsType = "vfat";
    };

  fileSystems."/data" =
    { device = "/dev/disk/by-uuid/3e653758-4b08-45d1-87fb-67cbefec0ffd";
      fsType = "ext4";
    };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };


  programs.ssh.startAgent = true;

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
    xkb.layout = "it";
    xkb.variant = "";
  };

  # Configure console keymap
  console.keyMap = "it";

  # Create the group i2c which is needed for external monitor brightness
  users.groups.i2c = {};
  users.groups.uinput = {};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sandro0198 = {
    isNormalUser = true;
    description = "Sandro";
    extraGroups = [ "networkmanager" "wheel" "uinput" "i2c" "vboxusers" "libvirtd" "dialout" ];
  };

  # services.printing.enable = true;
  # services.avahi = {
  #   enable = true;
  #   nssmdns4 = true;
  #   openFirewall = true;
  # };

  # systemd.timers."low-battery" = {
  #   wantedBy = [ "timers.target" ];
  #     timerConfig = {
  #       OnBootSec = "1m";
  #       OnUnitActiveSec = "1m";
  #       Unit = "low-battery.service";
  #     };
  # };

  systemd.services."low-battery" = let
    battery-threshold = "15";
  in {
    path = [ pkgs.libnotify pkgs.mako ];
    script = ''
      ${pkgs.bash}/bin/bash -c '
        export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$UID/bus"
        capacity=$(cat /sys/class/power_supply/BAT0/capacity)
        status=$(cat /sys/class/power_supply/BAT0/status)
        if [[ $capacity -lt ${battery-threshold} && $status != *Charging* ]]; then
          existing_id=$(cat /tmp/battery_notification_id.txt)
          if [[ -n $existing_id ]]; then
            notify-send -p -r $existing_id -u critical "Low battery: $capacity%" > /tmp/battery_notification_id.txt
          else
            notify-send -p -u critical "Low battery: $capacity%" > /tmp/battery_notification_id.txt
          fi
        else
          if [[ -f /tmp/battery_notification_id.txt ]]; then
            makoctl dismiss -n $(cat /tmp/battery_notification_id.txt)
            rm /tmp/battery_notification_id.txt
          fi
        fi
      '
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "${config.main-user}";
    };
  };

  home-manager.users.${config.main-user} = { config, ... }: {
    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";

      matchBlocks = {
        "homelab" = {
          hostname = "nextcloud.sanfio.eu";
          user = "homelab";
          identityFile = "~/.ssh/homelab";
        };

        "homelab_deploy" = {
          hostname = "nextcloud.sanfio.eu";
          user = "deployuser";
          identityFile = "~/.ssh/homelab_deploy";
          forwardAgent = true;
        };
      };
    };

    home.file = let config_path = "/data/dotfiles"; in {
      ".bashrc".source                        = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/bashrc";
      ".profile".source                       = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/profile";
      ".local/share/survey/".source           = config.lib.file.mkOutOfStoreSymlink "${config_path}/apps/survey";
      ".local/share/my_lock/".source          = config.lib.file.mkOutOfStoreSymlink "${config_path}/apps/my_lock";
      ".local/share/wl_fix/".source           = config.lib.file.mkOutOfStoreSymlink "${config_path}/apps/wl_fix";
      ".config/mimeapps.list".source          = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/xdg-open/mimeapps.list";
      ".config/libinput-gestures.conf".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/libinput-gestures/libinput-gestures.conf";
      ".config/alacritty/alacritty.toml".source             = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/alacritty/alacritty.toml";
      ".config/hypr/other/".source    = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/hypr/";
      ".config/caelestia/shell.json".source    = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/caelestia/shell.json";
      ".config/nvim/".source                  = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/nvim";
      ".config/kbapp/".source                 = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/kbapp";
      ".config/wireplumber/".source           = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/wireplumber";
      ".config/xournalpp/toolbar.ini".source  = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/xournalpp/toolbar.ini";
      ".mozilla/firefox/wsjk7r2r.default/chrome/userChrome.css".source  = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/mozilla/userChrome.css";
    };

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "23.11";
  };
}
