{ config, lib, pkgs, ... }:
{
  imports = [
    ./paperless.nix
    ./nextcloud.nix
    ./hass.nix
    ./kopia.nix
    # ./monitoring.nix
    # ./kavita.nix
  ];

  options.containers1 = {
    interface = lib.mkOption {
      description = "interface to use: something like wlp1s0";
      type = lib.types.str;
    };
  };

  config = {

    # Wireguard setup
    environment.systemPackages = [ pkgs.wireguard-tools ];
    networking.wireguard.interfaces = {
      wg0 = {
        ips = [ "16.0.0.1/24" ]; # The IP address for the server on the VPN
        listenPort = 51820;

        privateKeyFile = "/run/secrets/homelab_private_wireguard";
        peers = [
          {
            publicKey = "xEm6HUXJVJmhL5qQGycHewTLfmuyWQzIlI79XAV4vC4=";
           allowedIPs = [ "16.0.0.2/32" ]; # The IP address for the client on the VPN
          }
          {
            publicKey = "seCh6h/tgjowWqfpHzJrqdC1yyzshssuIBjkUkbr4kY=";
            allowedIPs = [ "16.0.0.3/32" ]; # The IP address for the client on the VPN
          }
          {
            publicKey = "ox9BtZ2FOxKlyugkjIne6J6WxOUqFgBADMjH3plJQWw=";
            allowedIPs = [ "16.0.0.4/32" ]; # The IP address for the client on the VPN
          }
        ];
      };
    };


    users.users.ddclient.isSystemUser = true;
    users.users.ddclient.group = "users";
    systemd.services.ddclient.serviceConfig.User = "ddclient";
    systemd.timers."ddclient" = {
      timerConfig = {
        Persistent = true;
      };
    };
    services.ddclient = let
      notify-script = pkgs.writeShellScript "notify-script.sh" ''
        BOT_TOKEN=$(cat /run/secrets/telegram_bot_api)
        CHAT_ID=$(cat /run/secrets/chat_id)
        ${pkgs.curl}/bin/curl -s --data "text=Ip has changed. Restart your wireguard connections." --data "chat_id=$CHAT_ID" 'https://api.telegram.org/bot'$BOT_TOKEN'/sendMessage'
      '';
    in {
      enable = true;
      ssl = true;
      use = "web, web='https://cloudflare.com/cdn-cgi/trace', web-skip='ip='";
      protocol = "cloudflare";
      zone = "sanfio.eu";
      domains = [ "sanfio.eu" "www.sanfio.eu" ];
      passwordFile = "/run/secrets/cloudflare_token";
      extraConfig = ''
        postscript=${notify-script}
      '';
    };

    users.users.kopia = {
      uid = 1555;
      isNormalUser = true;
      group = "backup_users";
      hashedPassword = "$y$j9T$Q.HD.crPHZVbigguUI.GV1$PTyklFYrHy/oQn/Bl.uEvyuXFqAVzy7qxq.mY7SH3B9";
    };
    users.groups.backup_users.gid = 1666;

    networking = {
      nat = {
        enable = true;
        internalInterfaces = ["ve-+" "wg0"];
        externalInterface = "${config.containers1.interface}";
        # Lazy IPv6 connectivity for the container
        enableIPv6 = true;
      };
      firewall = {
        # Open Wireguard port
        allowedUDPPorts = [ 51820 ];
      };
    };

    users.users.nginx.extraGroups = [ "acme" ];

    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      appendHttpConfig = ''
        # Add HSTS header with preloading to HTTPS requests.
        # Adding this header to HTTP requests is discouraged
        map $scheme $hsts_header {
            https   "max-age=31536000; includeSubdomains; preload";
        }
        add_header Strict-Transport-Security $hsts_header;

        # Enable CSP for your services.
        #add_header Content-Security-Policy "script-src 'self'; object-src 'none'; base-uri 'none';" always;

        # Minimize information leaked to other domains
        add_header 'Referrer-Policy' 'origin-when-cross-origin';
      '';

      virtualHosts = {
        "_" = {
          listen = [ { addr = "0.0.0.0"; port = 80; } ];
          locations."/" = {
            return = "301 https://$host$request_uri";
          };
        };
        "paper.sanfio.eu" = {
          onlySSL = true;
          sslCertificate = "/var/fullchain.pem";
          sslCertificateKey = "/var/privkey.pem";
          extraConfig = ''
            client_max_body_size 10G;
          '';
          locations."/" = {
            extraConfig = ''
              proxy_pass http://192.168.100.13:28981;
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";

              proxy_redirect off;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $server_name;
              add_header Referrer-Policy "strict-origin-when-cross-origin";
            '';
          };
        };
        "kopia.sanfio.eu" = {
          onlySSL = true;
          sslCertificate = "/var/fullchain.pem";
          sslCertificateKey = "/var/privkey.pem";
          extraConfig = ''
            proxy_buffering off;
            client_max_body_size 0;
          '';
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "https://192.168.100.14:51515/";
          };
        };
        # "kavita.sanfio.eu" = {
        #   onlySSL = true;
        #   sslCertificate = "/var/fullchain.pem";
        #   sslCertificateKey = "/var/privkey.pem";
        #   extraConfig = ''
        #     client_max_body_size 1G;
        #   '';
        #   locations."/" = {
        #     extraConfig = ''
        #       proxy_set_header X-Real-IP $remote_addr;
        #       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #       proxy_set_header X-NginX-Proxy true;
        #       proxy_set_header X-Forwarded-Proto http;
        #       proxy_pass http://192.168.100.15:5000/; # tailing / is important!
        #       proxy_set_header Host $host;
        #       proxy_cache_bypass $http_upgrade;
        #       proxy_redirect off;
        #     '';
        #   };
        # };
        "hass.sanfio.eu" = {
          onlySSL = true;
          sslCertificate = "/var/fullchain.pem";
          sslCertificateKey = "/var/privkey.pem";
          extraConfig = ''
            client_max_body_size 1G;
          '';
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "http://192.168.100.12:8123";
          };
          locations."/red" = {
            proxyWebsockets = true;
            proxyPass = "http://192.168.100.12:1880";
          };
        };
        # "metrics.sanfio.eu" = {
        #   onlySSL = true;
        #   sslCertificate = "/var/fullchain.pem";
        #   sslCertificateKey = "/var/privkey.pem";
        #   extraConfig = ''
        #     client_max_body_size 1G;
        #   '';
        #   locations."/" = {
        #     proxyWebsockets = true;
        #     proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
        #   };
        #   locations."/prometheus" = {
        #     proxyWebsockets = true;
        #     proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}";
        #   };
        # };
        "nextcloud.sanfio.eu" = {
          onlySSL = true;
          sslCertificate = "/var/fullchain.pem";
          sslCertificateKey = "/var/privkey.pem";
          extraConfig = ''
            proxy_buffering off;
            client_max_body_size 0;
          '';
          locations."/" = {
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
        };
      };
    };

    services.samba = {
      enable = true;
      enableNmbd = false;
      enableWinbindd = false;
      openFirewall = true;
      extraConfig = ''
        guest account = myuser
        map to guest = Bad User

        load printers = no
        printcap name = /dev/null

        log file = /var/log/samba/client.%I
        log level = 2
      '';

      shares = {
        nas = {
          "path" = "/mnt/nas";
          "guest ok" = "yes";
          "read only" = "no";
        };
      };
    };
    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
    services.avahi = {
      publish.enable = true;
      publish.userServices = true;
      # ^^ Needed to allow samba to automatically register mDNS records (without the need for an `extraServiceFile`
      nssmdns4 = true;
      # ^^ Not one hundred percent sure if this is needed- if it aint broke, don't fix it
      enable = true;
      openFirewall = true;
    };
  };
}
