{ node-red-home-assistant, node-red-contrib-sunevents, ... }: {
  containers.hass = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.12";

    bindMounts = {
      "/backup_dir_hass" = { hostPath = "/home/sserver/backup_dir/hass_data"; isReadOnly = false; };
    };
    bindMounts = {
      "/backup_dir_red" = { hostPath = "/home/sserver/backup_dir/nodered_data"; isReadOnly = false; };
    };
    config = { config, pkgs, lib, ... }: {
      environment.systemPackages = [ pkgs.mediamtx pkgs.ffmpeg ];

      systemd.tmpfiles.rules = [
        "d ${config.services.node-red.userDir}/node_modules 0755 node-red node-red"
        "L ${config.services.node-red.userDir}/node_modules/node-red-contrib-sunevents 0755 node-red node-red - ${node-red-contrib-sunevents}/lib/node_modules/node-red-contrib-sunevents"
        "L ${config.services.node-red.userDir}/node_modules/node-red-home-assistant 0755 node-red node-red - ${node-red-home-assistant}/lib/node_modules/node-red-home-assistant"
      ];

      services.node-red = {
        enable = true;
        configFile = "${pkgs.writeText "settings.js" ''
          module.exports = {
            uiHost: "0.0.0.0",
            httpAdminRoot: ''\'/red''\'
          }
        ''}";
      };

      systemd.timers."backup_hass" = {
        wantedBy = [ "timers.target" ];
          timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = "1m";
            # Persistent = true;
            # OnCalendar = "*-*-* 2:00:00";
            Unit = "backup_hass.service";
          };
      };

      systemd.services."backup_hass" = {
        script = ''
          ${pkgs.bash}/bin/bash -c '
            if [[ -f /var/lib/node-red/flows_hass.json ]]; then
              cp /var/lib/node-red/flows_hass.json /backup_dir_red
            fi

            if [[ -d /var/lib/hass ]]; then
              cp -r /var/lib/hass /backup_dir_hass
            fi
          '
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "hass";
        };
      };

      services.home-assistant = {
        enable = true;
        extraComponents = [
          # Components required to complete the onboarding
          "esphome"
          "met"
          "radio_browser"
          "zha"
          "generic"
          "ffmpeg"
        ];
        config = {
          # Includes dependencies for a basic setup
          # https://www.home-assistant.io/integrations/default_config/
          camera = [ { platform = "ffmpeg"; name = "cam2"; input = "-rtsp_transport tcp -i rtsp://192.168.100.10:8554/stream"; } ];
          http = {
              server_host = "0.0.0.0";
              trusted_proxies = [ "192.168.100.10" "192.168.122.40" ];
              use_x_forwarded_for = true;
            };
        };
      };

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 1880 8123 ];
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
