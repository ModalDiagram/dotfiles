{ ... }: {
  containers.nextcloud = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    ephemeral = true;
    bindMounts = {
      "/var/lib/nextcloud" = { hostPath = "/home/sserver/backup_dir/nextcloud_data"; isReadOnly = false; };
    };
    config = { config, pkgs, lib, ... }: {
      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud29;
        hostName = "192.168.122.40";
        settings = let
            prot = "http"; # or https
            host = "192.168.122.40";
            dir = "/nextcloud";
          in {
            overwriteprotocol = prot;
            overwritehost = host;
            overwritewebroot = dir;
            overwrite.cli.url = "${prot}://${host}${dir}/";
            htaccess.RewriteBase = dir;
          };
        config.adminpassFile = "${pkgs.writeText "adminpass" "test123"}"; # DON'T DO THIS IN PRODUCTION - the password file will be world-readable in the Nix Store!
        extraAppsEnable = true;
        extraApps = {
          inherit (config.services.nextcloud.package.packages.apps) calendar tasks;
          memories = pkgs.fetchNextcloudApp {
              sha256 = "sha256-DJPskJ4rTECTaO1XJFeOD1EfA3TQR4YXqG+NIti0UPE=";
              url = "https://github.com/pulsejet/memories/releases/download/v7.3.1/memories.tar.gz";
              license = "gpl3";
          };
          maps = pkgs.fetchNextcloudApp {
              sha256 = "sha256-LOQBR3LM7artg9PyD8JFVO/FKVnitALDulXelvPQFb8=";
              url = "https://github.com/nextcloud/maps/releases/download/v1.4.0/maps-1.4.0.tar.gz";
              license = "gpl3";
          };
        };
      };

      system.stateVersion = "24.05";

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 80 ];
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;

    };
  };
}
