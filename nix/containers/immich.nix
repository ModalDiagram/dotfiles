{ pkgs, ... }: {
  sops.secrets.GARAGE_RPC = { sopsFile = ../secrets/ente.json; format = "json"; uid = 994; };
  sops.secrets.GARAGE_KEY = { sopsFile = ../secrets/ente.json; format = "json"; uid = 995; };
  sops.secrets.GARAGE_SECRET = { sopsFile = ../secrets/ente.json; format = "json"; uid = 995; };
  sops.secrets.ENTE_ENCRYPTION = { sopsFile = ../secrets/ente.json; format = "json"; uid = 995; };
  sops.secrets.ENTE_HASH = { sopsFile = ../secrets/ente.json; format = "json"; uid = 995; };
  sops.secrets.ENTE_JWT = { sopsFile = ../secrets/ente.json; format = "json"; uid = 995; };

  containers.immich = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.16";
    bindMounts = {
      "/run/secrets/GARAGE_RPC" = { hostPath = "/run/secrets/GARAGE_RPC"; };
      "/run/secrets/GARAGE_KEY" = { hostPath = "/run/secrets/GARAGE_KEY"; };
      "/run/secrets/GARAGE_SECRET" = { hostPath = "/run/secrets/GARAGE_SECRET"; };
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

      systemd.timers."backup_homelab" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          Persistent = true;
          OnCalendar = "*-*-01,07,13,19,25,30 2:00:00";
          Unit = "backup_homelab.target";
        };
      };

      systemd.targets."backup_homelab" = {
        wants = [
          "backup_immich.service"
          "backup_ente.service"
        ];
        unitConfig = {
          StopWhenUnneeded = true;
        };
      };

      systemd.services."backup_immich" = {
        path = [ pkgs.kopia pkgs.util-linux ];
        script = ''
          ${pkgs.bash}/bin/bash -c '
            systemctl stop immich-server.service immich-machine-learning.service
            runuser -u immich -- kopia snapshot create /var/lib/immich
            systemctl start immich-server.service immich-machine-learning.service
          '
        '';
        serviceConfig = {
          Type = "oneshot";
        };
      };

      systemd.services."backup_ente" = {
        path = [ pkgs.kopia config.services.postgresql.package pkgs.util-linux ];
        script = ''
          ${pkgs.bash}/bin/bash -c '
            systemctl stop garage.service ente.service
            runuser -u ente -- pg_dump ente -f /var/lib/ente/ente_db.bkp
            runuser -u ente -- kopia snapshot create /var/lib/ente/
            runuser -u garage -- kopia snapshot create /var/lib/garage/
            systemctl start garage.service ente.service
          '
        '';
        serviceConfig = {
          Type = "oneshot";
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
          allowedTCPPorts = [ 2283 8080 3900 ];
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;

      services.garage = {
        enable = true;
        package = pkgs.garage_2;

        settings = {
          metadata_dir = "/var/lib/garage/meta";
          data_dir = "/var/lib/garage/data";

          replication_factor = 1;

          # Bind RPC locally
          rpc_bind_addr = "127.0.0.1:3901";
          rpc_public_addr = "127.0.0.1:3901";
          rpc_secret_file = "/run/secrets/GARAGE_RPC";

          # Bind S3 API locally for Ente
          s3_api = {
            s3_region = "garage";
            api_bind_addr = "0.0.0.0:3900";
            root_domain = ".s3.garage.localhost";
          };
        };
      };
      systemd.services.garage.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "garage";
      };

      services.ente = {
        api = {
          enable = true;
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
                endpoint = "es3.sfioretto.it";
                region = "garage";
                bucket = "ente-data";
                key._secret = "/run/secrets/GARAGE_KEY";
                secret._secret = "/run/secrets/GARAGE_SECRET";
                force_path_style = "true";
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
