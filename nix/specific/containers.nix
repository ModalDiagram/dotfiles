{  node-red-contrib-sunevents, node-red-home-assistant, ... }: {
  networking.interfaces.br0 = {
    virtual = true;
    ipv4.addresses = [
      {
        address = "10.0.0.1";
        prefixLength = 24;
      }
    ];
  };
  networking = {
    nftables = {
      enable = true;
      ruleset = ''
        table ip nat {
          chain PREROUTING {
            type nat hook prerouting priority dstnat; policy accept;
            iifname "ve-hass" tcp dport 8554 dnat to 192.168.122.1
          }
          chain POSTROUTING {
            type nat hook postrouting priority 100 ;
            masquerade
          }
        }
    '';
    };
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "enp1s0";
      # Lazy IPv6 connectivity for the container
      enableIPv6 = true;
      forwardPorts = [
        {
          sourcePort = 80;
          proto = "tcp";
          destination = "192.168.100.11:80";
        }
        {
          sourcePort = 8123;
          proto = "tcp";
          destination = "192.168.100.12:8123";
        }
        {
          sourcePort = 1880;
          proto = "tcp";
          destination = "192.168.100.12:1880";
        }
        {
          sourcePort = 28981;
          proto = "tcp";
          destination = "192.168.100.13:28981";
        }
      ];
    };
  };

  containers.paperless = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.13";

    config = { config, pkgs, lib, ... }: {
      services.node-red = {
        enable = true;
      };
      environment.etc."paperless-admin-pass".text = "admin";
      services.paperless = {
        enable = true;
        passwordFile = "/etc/paperless-admin-pass";
        address = "0.0.0.0";
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

      system.stateVersion = "24.05";
      services.resolved.enable = true;
    };
  };

  containers.hass = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.12";

    config = { config, pkgs, lib, ... }: {
      environment.systemPackages = [ pkgs.mediamtx pkgs.ffmpeg ];

      systemd.tmpfiles.rules = [
        "d ${config.services.node-red.userDir}/node_modules 0755 node-red node-red"
        "L ${config.services.node-red.userDir}/node_modules/node-red-contrib-sunevents 0755 node-red node-red - ${node-red-contrib-sunevents}/lib/node_modules/node-red-contrib-sunevents"
        "L ${config.services.node-red.userDir}/node_modules/node-red-home-assistant 0755 node-red node-red - ${node-red-home-assistant}/lib/node_modules/node-red-home-assistant"
      ];

      services.node-red = {
        enable = true;
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

  containers.nextcloud = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";
    config = { config, pkgs, lib, ... }: {
      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud29;
        hostName = "localhost";
        settings = {
          trusted_domains = [ "192.168.100.11" "192.168.122.40" ];
        };
        config.adminpassFile = "${pkgs.writeText "adminpass" "test123"}"; # DON'T DO THIS IN PRODUCTION - the password file will be world-readable in the Nix Store!
      };

      system.stateVersion = "23.11";

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
