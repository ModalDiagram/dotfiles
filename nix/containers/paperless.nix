{ config, ... }: let ipaddr = config.containers1.ipaddr; in {
  containers.paperless = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.13";
    bindMounts = {
      "/run/secrets/paperless_password" = { hostPath = "/run/secrets/paperless_password"; };
    };
    config = { config, pkgs, lib, ... }: {
      environment.systemPackages = [ pkgs.kopia ];

      environment.etc."paperless_password" = {
        source = "/run/secrets/paperless_password";
        mode = "0400";
        user = "paperless";
      };
      system.stateVersion = "24.05";

      systemd.timers."backup_paperless" = {
        wantedBy = [ "timers.target" ];
          timerConfig = {
            Persistent = true;
            OnCalendar = "*-*-* 2:00:00";
            Unit = "backup_paperless.service";
          };
      };

      systemd.services."backup_paperless" = {
        path = [ config.services.postgresql.package pkgs.kopia ];
        script = ''
          ${pkgs.bash}/bin/bash -c '
            pg_dump paperless -f /var/lib/paperless/postgresqlbkp.bak
            kopia snapshot create /var/lib/paperless
          '
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "paperless";
        };
      };

      services.paperless = {
        enable = true;
        passwordFile = "/etc/paperless_password";
        address = "0.0.0.0";
        settings = {
          PAPERLESS_URL = "https://" + "${ipaddr}";
          PAPERLESS_FORCE_SCRIPT_NAME = "/paper";
          PAPERLESS_USE_X_FORWARD_HOST = true;
          PAPERLESS_USE_X_FORWARD_PORT = true;
          PAPERLESS_DBHOST = "/run/postgresql";
        };
      };

      services.postgresql = {
        enable = true;

        # Ensure the database, user, and permissions always exist
        ensureDatabases = [ "paperless" ];
        ensureUsers = [
          { name = "paperless";
            ensureDBOwnership = true;
          }
        ];
      };

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 28981 ];
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;

    };
  };
}