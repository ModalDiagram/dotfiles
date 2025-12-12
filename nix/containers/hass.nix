{ pkgs, ... }: {
  sops.secrets.radicale_psswd = { sopsFile = ../secrets/containers.json; format = "json"; };
  sops.secrets.paperless_password = { sopsFile = ../secrets/containers.json; format = "json"; };
  sops.secrets.gitea_password = { sopsFile = ../secrets/containers.json; format = "json"; };

  containers.hass = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.12";
    # Hass crashes if the device is not present
    allowedDevices = [
      {
        modifier = "rwm";
        node = "/dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20231008112217-if00";
      }
    ];

    bindMounts = {
      sonoff = {
        hostPath = "/dev/serial/by-id";
        mountPoint = "/dev/serial/by-id";
        isReadOnly = false;
      };
      tty = {
        hostPath = "/dev/ttyACM0";
        mountPoint = "/dev/ttyACM0";
        isReadOnly = false;
      };
      "/run/secrets/radicale_psswd" = { hostPath = "/run/secrets/radicale_psswd"; };
      "/run/secrets/paperless_password" = { hostPath = "/run/secrets/paperless_password"; };
      "/run/secrets/gitea_password" = { hostPath = "/run/secrets/gitea_password"; };
      "/var/lib/kavita_library/suwayomi/" = {
        hostPath = "/opt/suwayomi/downloads";
        isReadOnly = false;
      };
    };

    config = { config, lib, ... }: {
      nixpkgs.pkgs = pkgs;
      environment.systemPackages = [ pkgs.mediamtx pkgs.ffmpeg pkgs.kopia ];

      environment.etc."radicale_psswd" = {
        source = "/run/secrets/radicale_psswd";
        mode = "0400";
        user = "radicale";
      };
      environment.etc."paperless_password" = {
        source = "/run/secrets/paperless_password";
        mode = "0400";
        user = "paperless";
      };
      environment.etc."gitea_password" = {
        source = "/run/secrets/gitea_password";
        mode = "0400";
        user = "gitea";
      };

      users.users.radicale.home = "/var/lib/radicale";

      systemd.timers."backup_paperless" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          Persistent = true;
          OnCalendar = "*-*-02,04,06,08,10,12,14,16,18,20,22,24,26,28,30 2:00:00";
          Unit = "backup_paperless.service";
        };
      };

      systemd.timers."backup_gitea" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          Persistent = true;
          OnCalendar = "*-*-02,04,06,08,10,12,14,16,18,20,22,24,26,28,30 2:00:00";
          Unit = "backup_gitea.service";
        };
      };

      systemd.timers."backup_radicale" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          Persistent = true;
          OnCalendar = "*-*-02,04,06,08,10,12,14,16,18,20,22,24,26,28,30 2:00:00";
          Unit = "backup_radicale.service";
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

      systemd.services."backup_gitea" = {
        path = [ config.services.postgresql.package pkgs.kopia ];
        script = ''
          ${pkgs.bash}/bin/bash -c '
            pg_dump gitea -f /var/lib/gitea/postgresqlbkp.bak
            kopia snapshot create /var/lib/gitea
          '
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "gitea";
        };
      };

      systemd.services."backup_radicale" = {
        path = [ pkgs.kopia ];
        script = ''
          ${pkgs.bash}/bin/bash -c '
            kopia snapshot create /var/lib/radicale
          '
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "radicale";
        };
      };

      services.kavita = {
        enable = true;
        tokenKeyFile = "/var/lib/kavita/tokenkey.txt";
        settings = {
          IpAddresses = "0.0.0.0";
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
            { "invalidate_digital_signatures": true, "continue_on_soft_render_error": true }
          '';
        };
      };

      services.postgresql = {
        enable = true;

        # Ensure the database, user, and permissions always exist
        ensureDatabases = [ "paperless" "gitea" ];
        ensureUsers = [
          { name = "paperless";
            ensureDBOwnership = true;
          }
          {
            name = "gitea";
            ensureDBOwnership = true;
          }
        ];
      };

      services.gitea = {
        enable = true;
        appName = "Gitea_Homelab";
        database = {
          type = "postgres";
          passwordFile = "/etc/gitea_password";
        };
        settings.server = {
          DOMAIN = "git.sanfio.eu";
          ROOT_URL = "https://git.sanfio.eu/";
          HTTP_ADDR = "0.0.0.0";
          HTTP_PORT = 3001;
        };
      };

      services.radicale = {
        enable = true;
        settings = {
          server.hosts = [ "0.0.0.0:5232" ];
          auth = {
            type = "htpasswd";
            htpasswd_filename = "/etc/radicale_psswd";
            htpasswd_encryption = "bcrypt";
          };
        };
      };

      services.node-red = {
        enable = true;
        configFile = "${pkgs.writeText "settings.js" ''
          module.exports = {
            uiHost: "0.0.0.0",
            httpAdminRoot: ''\'/red''\'
          }
        ''}";
      };

      services.home-assistant = {
        enable = true;
        extraComponents = [
          # Components required to complete the onboarding
          "esphome"
          "met"
          "radio_browser"
          "zha"
          "mobile_app"
          "generic"
          "ffmpeg"
        ];
        config = {
          homeassistant = {
            external_url = "https://hass.sanfio.eu";
          };
          mobile_app = {};
          camera = [ { platform = "ffmpeg"; name = "cam2"; input = "-rtsp_transport tcp -i rtsp://192.168.100.10:8554/stream"; } ];
          http = {
              trusted_proxies = [ "192.168.100.10" ];
              use_x_forwarded_for = true;
            };
        };
      };

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 1880 5232 8123 28981 3001 5000 ];
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      system.stateVersion = "24.05";
      services.resolved.enable = true;
    };
  };
}
