{ pkgs, config, ... }: {
  # sops.secrets."minio.env" = {
  #   sopsFile = ../secrets/minio.env; format = "dotenv";
  #   uid = config.containers.immich.config.users.users.minio.uid;
  # };
  sops.secrets.MINIO_ROOT_USER = {
    sopsFile = ../secrets/ente.json; format = "json"; uid = 995;
  };
  sops.secrets.MINIO_ROOT_PASSWORD = {
    sopsFile = ../secrets/ente.json; format = "json"; uid = 995;
  };
  sops.secrets.ENTE_ENCRYPTION = {
    sopsFile = ../secrets/ente.json; format = "json"; uid = 995;
  };
  sops.secrets.ENTE_HASH = {
    sopsFile = ../secrets/ente.json; format = "json"; uid = 995;
  };
  sops.secrets.ENTE_JWT = {
    sopsFile = ../secrets/ente.json; format = "json"; uid = 995;
  };

  containers.immich = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.16";
    bindMounts = {
      # "/run/secrets/minio.env" = { hostPath = "/run/secrets/minio.env"; };
      "/run/secrets/MINIO_ROOT_USER" = { hostPath = "/run/secrets/MINIO_ROOT_USER"; };
      "/run/secrets/MINIO_ROOT_PASSWORD" = { hostPath = "/run/secrets/MINIO_ROOT_PASSWORD"; };
      "/run/secrets/ENTE_ENCRYPTION" = { hostPath = "/run/secrets/ENTE_ENCRYPTION"; };
      "/run/secrets/ENTE_HASH" = { hostPath = "/run/secrets/ENTE_HASH"; };
      "/run/secrets/ENTE_JWT" = { hostPath = "/run/secrets/ENTE_JWT"; };
    };

    config = { config, lib, ... }: {
      nixpkgs.pkgs = pkgs;

      environment.systemPackages = with pkgs; [
        kopia
        exiftool
        ente-cli
      ];

      users.users.immich.home = "/var/lib/immich";

      systemd.timers."backup_immich" = {
        wantedBy = [ "timers.target" ];
          timerConfig = {
            Persistent = true;
            OnCalendar = "*-*-02,04,06,08,10,12,14,16,18,20,22,24,26,28,30 2:00:00";
            Unit = "backup_immich.service";
          };
      };

      systemd.services."backup_immich" = {
        path = [ pkgs.kopia ];
        script = ''
          ${pkgs.bash}/bin/bash -c '
            kopia snapshot create /var/lib/immich
          '
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "immich";
        };
      };

      services.immich = {
        enable = true;
        port = 2283;
        host = "0.0.0.0";
      };
      system.stateVersion = "24.05";

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 2283 9000 8080 9001 ];
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;

      # services.minio = {
      #   enable = true;
      #   region = "us-east-1";
      #   rootCredentialsFile = "/run/secrets/minio.env";
      # };

      # systemd.services.minio.environment.MINIO_SERVER_URL = "https://es3.sfioretto.it";

      services.ente = {
        api = {
          enable = false;
          enableLocalDB = true;
          domain = "eapi.sfioretto.it";
          settings = {
            apps = {
              accounts = "https://eaccounts.sfioretto.it";
            };
            internal.admin = "1580559962386438";

            webauthn = {
              rpid = "eaccounts.sfioretto.it";
              rporigins = [ "https://eaccounts.sfioretto.it" ];
            };
            s3 = {
              use_path_style_urls = true;
              b2-eu-cen = {
                endpoint = "https://es3.sfioretto.it";
                region = "us-east-1";
                bucket = "ente";
                key._secret = "/run/secrets/MINIO_ROOT_USER";
                secret._secret = "/run/secrets/MINIO_ROOT_PASSWORD";
              };
            };
            key = {
              encryption._secret = "/run/secrets/ENTE_ENCRYPTION";
              hash._secret = "/run/secrets/ENTE_HASH";
            };
            jwt.secret._secret = "/run/secrets/ENTE_JWT";
          };
        };
      };

    };
  };
}
