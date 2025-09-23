{ pkgs, ... }: {
  sops.secrets.nextcloud_password = { sopsFile = ../secrets/containers.json; format = "json"; };

  containers.nextcloud = let
    kopia-seafile =
      (pkgs.writeShellScriptBin "kopia-seafile" ''
        export XDG_CONFIG_HOME=/var/lib/seafile/.config
        export XDG_CACHE_HOME=/var/lib/seafile/.cache
        exec ${pkgs.kopia}/bin/kopia "$@"
      '');
  in {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    bindMounts = {
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
        kopia-seafile
      ];

      services.cron.enable = true;

      systemd.timers."backup_nextcloud" = {
        wantedBy = [ "timers.target" ];
          timerConfig = {
            Persistent = true;
            OnCalendar = "*-*-02,04,06,08,10,12,14,16,18,20,22,24,26,28,30 2:00:00";
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
        package = pkgs.nextcloud31;
        hostName = "nextcloud.sanfio.eu";

        # for cache
        configureRedis = true;
        phpOptions."opcache.interned_strings_buffer" = "16";
        maxUploadSize = "100G";
        fastcgiTimeout = 3600;

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
            trusted_proxies = [ "192.168.100.10" ];
            maintenance_window_start = 1;
            default_phone_region = "IT";
            max_input_time = "3600";
            max_execution_time = "3600";
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
        ensureDatabases = [ "nextcloud" "gitea" ];
        ensureUsers = [
          { name = "nextcloud";
            ensureDBOwnership = true;
          }
          {
            name = "gitea";
            ensureDBOwnership = true;
          }
        ];
      };

      services.seafile = {
        enable = false;

        adminEmail = "seafile@sanfio.eu";
        initialAdminPassword = "prova";
        seafileSettings = {
          fileserver = {
            host = "ipv4:0.0.0.0";
            port = 8082;
          };
        };

        seahubAddress = "0.0.0.0:8083";
        seahubExtraConf = ''
          ALLOWED_HOSTS = ["seafile.sanfio.eu", "localhost"]
        '';

        ccnetSettings.General.SERVICE_URL = "https://seafile.sanfio.eu";
      };

      services.gitea = {
        enable = true;
        appName = "Gitea_Homelab";
        database = {
          type = "postgres";
          password = "gitea";
        };
        settings.server = {
          DOMAIN = "git.sanfio.eu";
          ROOT_URL = "https://git.sanfio.eu/";
          HTTP_ADDR = "0.0.0.0";
          HTTP_PORT = 3001;
        };
      };

      system.stateVersion = "24.05";

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 80 3001 ];
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;

    };
  };
}
