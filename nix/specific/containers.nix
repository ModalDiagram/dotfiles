{  node-red-contrib-sunevents, node-red-home-assistant, ... }: {
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
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."0.0.0.0" = {
      extraConfig = ''
        proxy_buffering off;
        client_max_body_size 1G;
      '';
      locations."^~ /.well-known" = {
        priority = 9000;
        extraConfig = ''
          absolute_redirect off;
          location ~ ^/\\.well-known/(?:carddav|caldav)$ {
            return 301 /nextcloud/remote.php/dav;
          }
          location ~ ^/\\.well-known/host-meta(?:\\.json)?$ {
            return 301 /nextcloud/public.php?service=host-meta-json;
          }
          location ~ ^/\\.well-known/(?!acme-challenge|pki-validation) {
            return 301 /nextcloud/index.php$request_uri;
          }
          try_files $uri $uri/ =404;
        '';
      };
      locations."/nextcloud/" = {
        priority = 9999;
        extraConfig = ''
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-NginX-Proxy true;
          proxy_set_header X-Forwarded-Proto http;
          proxy_pass http://192.168.100.11:80/; # tailing / is important!
          proxy_set_header Host $host;
          proxy_cache_bypass $http_upgrade;
          proxy_redirect off;
        '';
      };
      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://192.168.100.12:8123";
      };
      locations."/red" = {
        proxyWebsockets = true;
        proxyPass = "http://192.168.100.12:1880";
      };
      locations."/paper" = {
        proxyWebsockets = true;
        proxyPass = "http://192.168.100.13:28981";
      };
    };
  };

  containers.paperless = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.13";
    config = { config, pkgs, lib, ... }: {
      system.stateVersion = "24.05";

      environment.etc."paperless-admin-pass".text = "admin";
      services.paperless = {
        enable = true;
        passwordFile = "/etc/paperless-admin-pass";
        address = "0.0.0.0";
        settings = {
          PAPERLESS_FORCE_SCRIPT_NAME = "/paper";
          PAPERLESS_USE_X_FORWARD_HOST = true;
          PAPERLESS_USE_X_FORWARD_PORT = true;
        };
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

  containers.hass = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.12";

    config = { config, pkgs, lib, ... }: {
      environment.systemPackages = [ pkgs.mediamtx pkgs.ffmpeg ];

      # TOFIX
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

  containers.nextcloud = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    config = { config, pkgs, lib, ... }: {
      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud29;
        hostName = "192.168.122.40";
        settings = let
            prot = "http"; # or https
            host = "192.168.122.40";
            dir = "/nextcloud";
          in {
            overwriteprotocol = prot;
            overwritehost = host;
            overwritewebroot = dir;
            overwrite.cli.url = "${prot}://${host}${dir}/";
            htaccess.RewriteBase = dir;
          };
        config.adminpassFile = "${pkgs.writeText "adminpass" "test123"}"; # DON'T DO THIS IN PRODUCTION - the password file will be world-readable in the Nix Store!
      };

      system.stateVersion = "24.05";

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
