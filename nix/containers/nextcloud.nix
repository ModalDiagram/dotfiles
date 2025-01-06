{ pkgs, ... }: {
  containers.nextcloud = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    bindMounts = {
      "/backup_repo" = { hostPath = "/home/kopia/backups"; isReadOnly = false; };
      "/run/secrets/nextcloud_password" = { hostPath = "/run/secrets/nextcloud_password"; };
      # fuse is needed to mount inside the containers (eg kopia backups)
      fuse = {
        hostPath = "/dev/fuse"; mountPoint = "/dev/fuse"; isReadOnly = false;
      };
    };
    allowedDevices = [
      {
        modifier = "rwm";
        node = "/dev/fuse";
      }
    ];

    config = { config, lib, ... }: {
      nixpkgs.pkgs = pkgs;
      environment.etc."nextcloud_password" = {
        source = "/run/secrets/nextcloud_password";
        mode = "0400";
        user = "nextcloud";
      };

      environment.systemPackages = with pkgs; [
        kopia
        ffmpeg
        nodejs
        exiftool
        config.services.nextcloud.occ
      ];

      services.cron.enable = true;

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
        package = pkgs.nextcloud30;
        hostName = "nextcloud.sanfio.eu";

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
            host = "nextcloud.sanfio.eu";
          in {
            overwriteprotocol = prot;
            overwritehost = host;
            overwrite.cli.url = "${prot}://${host}";
            trusted_proxies = [ "192.168.100.10" "16.0.0.2" ];
            maintenance_window_start = 1;
            opcache.interned_strings_buffer = 64;
          };
        config.adminpassFile = "/etc/nextcloud_password";

        appstoreEnable = true;
        extraAppsEnable = true;
        extraApps = {
          inherit (config.services.nextcloud.package.packages.apps) calendar tasks;
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
