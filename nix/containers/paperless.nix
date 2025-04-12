{ pkgs, ... }: {
  sops.secrets.paperless_password = { sopsFile = ../secrets/containers.json; format = "json"; };

  containers.paperless = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.13";
    bindMounts = {
      "/run/secrets/paperless_password" = { hostPath = "/run/secrets/paperless_password"; };
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
          PAPERLESS_URL = "https://paper.sanfio.eu";
          PAPERLESS_USE_X_FORWARD_HOST = true;
          PAPERLESS_USE_X_FORWARD_PORT = true;
          PAPERLESS_DBHOST = "/run/postgresql";
          PAPERLESS_OCR_USER_ARGS = ''
            { "invalidate_digital_signatures": true }
          '';
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
