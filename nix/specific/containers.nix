{ config, pkgs, lib, modulesPath, home-manager, node-red-contrib-sunevents, node-red-home-assistant, ... }: {
  networking = {
    # nftables = {
    #   enable = true;
    #   ruleset = ''
    #     table ip nat {
    #       chain PREROUTING {
    #         type nat hook prerouting priority dstnat; policy accept;
    #         iifname "enp1s0" tcp dport 80 dnat to 192.168.100.11
    #       }
        # }
    # '';
    # };
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
          destination = "192.168.100.13:1880";
        }
      ];
    };
  };

  containers.node-red = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.13";

    config = { config, pkgs, lib, ... }: {
      services.node-red = {
        enable = true;
      };

      systemd.tmpfiles.rules = [
        "d ${config.services.node-red.userDir}/node_modules 0755 node-red node-red"
        "L ${config.services.node-red.userDir}/node_modules/node-red-contrib-sunevents 0755 node-red node-red - ${node-red-contrib-sunevents}/lib/node_modules/node-red-contrib-sunevents"
        "L ${config.services.node-red.userDir}/node_modules/node-red-home-assistant 0755 node-red node-red - ${node-red-home-assistant}/lib/node_modules/node-red-home-assistant"
      ];


      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 1880 ];
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
      services.home-assistant = {
        enable = true;
        extraComponents = [
          # Components required to complete the onboarding
          "esphome"
          "met"
          "radio_browser"
        ];
        config = {
          # Includes dependencies for a basic setup
          # https://www.home-assistant.io/integrations/default_config/
          default_config = {};
        };
      };

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 8123 ];
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
