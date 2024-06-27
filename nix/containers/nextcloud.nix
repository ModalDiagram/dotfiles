{ config, ... }: let ipaddr = config.containers1.ipaddr; in {
  containers.nextcloud = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    bindMounts = {
      "/backup_repo" = { hostPath = "/home/kopia/backups"; isReadOnly = false; };
      "/run/secrets/nextcloud_password" = { hostPath = "/run/secrets/nextcloud_password"; };
    };

    config = { config, pkgs, lib, ... }: {
      environment.etc."nextcloud_password" = {
        source = "/run/secrets/nextcloud_password";
        mode = "0400";
        user = "nextcloud";
      };

      environment.systemPackages = [ pkgs.kopia ];

      systemd.timers."backup_nextcloud" = {
        wantedBy = [ "timers.target" ];
          timerConfig = {
            Persistent = true;
            OnCalendar = "*-*-* 2:00:00";
            Unit = "backup_nextcloud.service";
          };
      };

      systemd.services."backup_nextcloud" = {
        path = [ pkgs.util-linux config.services.nextcloud.occ config.services.postgresql.package pkgs.kopia ];
        script = ''
          ${pkgs.bash}/bin/bash -c '
            nextcloud-occ maintenance:mode --on
            pg_dump nextcloud -f /var/lib/nextcloud/data/postgresqlbkp.bak
            kopia snapshot create /var/lib/nextcloud/data
            nextcloud-occ maintenance:mode --off
          '
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "nextcloud";
        };
      };

      systemd.services."nextcloud-setup" = {
        requires = ["postgresql.service"];
        after = ["postgresql.service"];
      };

      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud29;
        hostName = "${ipaddr}";

        # Database options
        config = {
          dbtype = "pgsql";
          dbuser = "nextcloud";
          dbhost = "/run/postgresql";
          dbname = "nextcloud";
          dbpassFile = "/etc/nextcloud_password";
        };

        settings = let
            prot = "https"; # or https
            host = "${ipaddr}";
            dir = "/nextcloud";
          in {
            overwriteprotocol = prot;
            overwritehost = host;
            overwritewebroot = dir;
            overwrite.cli.url = "${prot}://${host}${dir}/";
            htaccess.RewriteBase = dir;
          };
        config.adminpassFile = "/etc/nextcloud_password";

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

      services.postgresql = {
        enable = true;

        # Ensure the database, user, and permissions always exist
        ensureDatabases = [ "nextcloud" ];
        ensureUsers = [
          { name = "nextcloud";
            ensureDBOwnership = true;
          }
        ];
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
