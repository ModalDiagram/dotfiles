{ node-red-home-assistant, node-red-contrib-sunevents, pkgs, ... }: {
  containers.hass = {
    autoStart = false;
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
    };

    config = { config, lib, ... }: {
      nixpkgs.pkgs = pkgs;
      environment.systemPackages = [ pkgs.mediamtx pkgs.ffmpeg ];

      # systemd.tmpfiles.rules = [
        # "d ${config.services.node-red.userDir}/node_modules 0755 node-red node-red"
        # "L ${config.services.node-red.userDir}/node_modules/node-red-contrib-sunevents 0755 node-red node-red - ${node-red-contrib-sunevents}/lib/node_modules/node-red-contrib-sunevents"
        # "L ${config.services.node-red.userDir}/node_modules/node-red-home-assistant 0755 node-red node-red - ${node-red-home-assistant}/lib/node_modules/node-red-home-assistant"
      # ];

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
