# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = [ "acer_wmi" ];
  boot.extraModprobeConfig = ''
    options ath9k nohwcrypt=1
  '';

  services.logind.lidSwitch = "ignore";
  # Settings needed for flakes
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "deployuser" ];
  security.pam.sshAgentAuth.enable = true;
  security.pam.sshAgentAuth.authorizedKeysFiles = [ "/etc/ssh/authorized_keys/%u" ];
  security.pam.services.sudo.sshAgentAuth = true;

  environment.systemPackages = with pkgs; [
    git vim gh ripgrep fd brightnessctl kopia bat cargo jdk openssl
  ];
  # Rules for brightnessctl
  services.udev.extraRules = ''
        KERNEL=="event[0-9]*", SUBSYSTEM=="backlight", GROUP="video"
  '';
  users.extraUsers.homelab = {
    createHome = true;
    extraGroups = [ "wheel" "video" "audio" "disk" "networkmanager" ];
    group = "users";
    home = "/home/homelab";
    isNormalUser = true;
    uid = 1000;
  };

  users.groups.deployuser = {};
  users.users.deployuser = {
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    group = "deployuser";
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO6a5zjo0tk8G879SEmCKHKrF2NJEMdzbM9C++V+GK79 sandro0198@lenovo" ];
  };

  systemd.timers."kopia_backup" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        Persistent = true;
        OnCalendar = "*-*-* 2:00:00";
        Unit = "kopia_backup.service";
      };
  };

  systemd.services."kopia_backup" = {
    wants = [ "bw_backup.service" ];
    path = [ pkgs.kopia ];
    script = ''
      kopia snapshot create /mnt/homelab/backup/
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  sops.secrets.bw_session = { sopsFile = ../../secrets/containers.json; format = "json"; };
  sops.secrets.backup_password = { sopsFile = ../../secrets/containers.json; format = "json"; };

  systemd.services."bw_backup" = {
    path = [ pkgs.bitwarden-cli pkgs.openssl ];
    script = ''
      export BW_SESSION=$(cat /run/secrets/bw_session)
      export BACKUP_PASSWORD=$(cat /run/secrets/backup_password)
      export BITWARDENCLI_APPDATA_DIR=/root/.config/bitwarden
      bw export --raw --session $BW_SESSION --format json | openssl enc -aes-256-cbc -pbkdf2 -iter 600000 -k $BACKUP_PASSWORD -out /mnt/homelab/backup/bw_export.enc
      chown homelab /mnt/homelab/backup/bw_export.enc
    '';
  };

  systemd.timers."subitoTracker" = {
    enable = false;
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "30m";
        OnUnitActiveSec = "30m";
        Unit = "subitoTracker.service";
      };
  };

  systemd.services."subitoTracker" = let python = pkgs.python311.withPackages (ps: with ps; [ requests python-telegram-bot beautifulsoup4 ]);
  in {
    script = ''
      ${python}/bin/python /home/homelab/projects/subitoTracker/src/main.py > /tmp/log1.txt
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "${config.main-user}";
    };
  };


  system.stateVersion = "24.05";
  home-manager.users.${config.main-user} = { config, ... }: {
    home.stateVersion = "24.05";
    home.file = let config_path = "/home/homelab/dotfiles"; in {

      ".config/nvim/".source                  = config.lib.file.mkOutOfStoreSymlink "${config_path}/conf.d/nvim";
    };
  };

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
  services.xserver.xkb = {
    layout = "it";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "it";

  services.openssh.enable = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/sda2";
      preLVM = true;
    };
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/1748cf2a-043e-4838-83af-f0db5eb0200b";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3CD3-4374";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/d17146b6-7661-4338-8733-6f6bb342ccf2"; }
    ];

  networking.useDHCP = lib.mkDefault true;
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 22 443 25565 ];
      extraCommands = ''
        iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o wlan0 -j MASQUERADE
      '';
    };
  };
  networking.hostName = "homelab";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
