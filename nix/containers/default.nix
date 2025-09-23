{ config, lib, pkgs, ... }:
{
  imports = [
    ./paperless.nix
    ./nextcloud.nix
    ./hass.nix
    ./kopia.nix
    ./docker.nix
    ./immich.nix
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
    sops.secrets.homelab_private_wireguard = { sopsFile = ../secrets/containers.json; format = "json"; };

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
            publicKey = "Vags59KzjejAXHPfmHRTDBm6/9+7HGSqOUK3mjuuzgE=";
            allowedIPs = [ "16.0.0.3/32" ]; # The IP address for the client on the VPN
          }
          {
            publicKey = "ox9BtZ2FOxKlyugkjIne6J6WxOUqFgBADMjH3plJQWw=";
            allowedIPs = [ "16.0.0.4/32" ]; # The IP address for the client on the VPN
          }
          {
            publicKey = "HXDUs/65a/IVlK3LDGr8uLzhRfLPxS38GhHPBx7PMVE=";
            allowedIPs = [ "16.0.0.100/32" ]; # The IP address for the client on the VPN
          }
        ];
      };
    };

    sops.secrets.cloudflare_token = { sopsFile = ../secrets/containers.json; format = "json"; };

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
      usev4 = "webv4, webv4='https://cloudflare.com/cdn-cgi/trace', web-skip='ip='";
      usev6 = "";
      protocol = "cloudflare";
      zone = "sanfio.eu";
      domains = [ "sanfio.eu" "www.sanfio.eu" ];
      passwordFile = "/run/secrets/cloudflare_token";
      extraConfig = ''
        postscript=${notify-script}
      '';
    };

    systemd.timers."backup_seafile" = {
        wantedBy = [ "timers.target" ];
          timerConfig = {
            Persistent = true;
            OnCalendar = "*-*-02,04,06,08,10,12,14,16,18,20,22,24,26,28,30 2:00:00";
            Unit = "backup_seafile.service";
          };
      };

      systemd.services."dump_seafile_db" = {
        path = [ pkgs.docker ];
        script = ''
          ${pkgs.bash}/bin/bash -c '
            docker exec seafile-mysql mariadb-dump  -uroot -pseafile --opt ccnet_db > /opt/seafile-data/backup/ccnet_db.sql
            docker exec seafile-mysql mariadb-dump  -uroot -pseafile --opt seafile_db > /opt/seafile-data/backup/seafile_db.sql
            docker exec seafile-mysql mariadb-dump  -uroot -pseafile --opt seahub_db > /opt/seafile-data/backup/seahub_db.sql
          '
        '';
        serviceConfig = {
          Type = "oneshot";
        };
      };

      systemd.services."backup_seafile" = {
        path = [ pkgs.kopia ];
        script = ''
          ${pkgs.bash}/bin/bash -c '
            kopia snapshot create /opt/seafile-data/
          '
        '';
        requires = [ "dump_seafile_db.service" ];
        after = [ "dump_seafile_db.service" ];
        serviceConfig = {
          Type = "oneshot";
          User = "kopia";
        };
      };



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
        allowedTCPPorts = [ 8888 3000 ];
        allowedUDPPorts = [ 51820 53 ];
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "acme@sanfio.eu";
        extraLegoFlags = [ "--dns.propagation-wait" "10s" ];
        dnsProvider = "cloudflare";
        credentialFiles = {
         "CLOUDFLARE_DNS_API_TOKEN_FILE" = "/run/secrets/cloudflare_token";
        };
      };
    };

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
          enableACME = true;
          acmeRoot = null;
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
          enableACME = true;
          acmeRoot = null;
          extraConfig = ''
            proxy_buffering off;
            client_max_body_size 0;
          '';
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "https://192.168.100.14:51515/";
            extraConfig = ''
              grpc_pass grpcs://192.168.100.14:51515;
            '';
          };
        };
        "hass.sanfio.eu" = {
          onlySSL = true;
          enableACME = true;
          acmeRoot = null;
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
        "stocks.sanfio.eu" = {
          onlySSL = true;
          enableACME = true;
          acmeRoot = null;
          extraConfig = ''
            client_max_body_size 1G;
          '';
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:3333/";
          };
        };
        "photos.sanfio.eu" = {
          onlySSL = true;
          enableACME = true;
          acmeRoot = null;
          extraConfig = ''
            client_max_body_size 0;
          '';
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "http://192.168.100.16:2283";
          };
        };
        "seafile.sanfio.eu" = {
          onlySSL = true;
          enableACME = true;
          acmeRoot = null;
          extraConfig = ''
            proxy_set_header   X-Real-IP $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   X-Forwarded-Host $server_name;
            proxy_read_timeout  1200s;
            client_max_body_size 0;
          '';
          locations = {
            "/" = {
              proxyPass = "http://127.0.0.1:8000";
            };
            "/seafhttp" = {
              proxyPass = "http://127.0.0.1:8082";
              extraConfig = ''
                rewrite ^/seafhttp(.*)$ $1 break;
                proxy_connect_timeout  36000s;
                proxy_read_timeout  36000s;
                proxy_send_timeout  36000s;
                send_timeout  36000s;
              '';
            };
            "/seafdav/" = {
              proxyPass = "http://127.0.0.1:8080/seafdav/";
            };
            "/:dir_browser" = {
              proxyPass = "http://127.0.0.1:8080/:dir_browser";
            };
          };
        };
        "git.sanfio.eu" = {
          onlySSL = true;
          enableACME = true;
          acmeRoot = null;
          extraConfig = ''
            client_max_body_size 0;
          '';
          locations."/" = {
            proxyPass = "http://192.168.100.11:3001";
          };
        };
        "nextcloud.sanfio.eu" = {
          onlySSL = true;
          enableACME = true;
          acmeRoot = null;
          extraConfig = ''
            proxy_buffering off;
            client_max_body_size 0;
            proxy_connect_timeout 3600s;
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;
            fastcgi_read_timeout 3600s;
            fastcgi_buffers 64 4K;
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
      nmbd.enable = false;
      winbindd.enable = false;
      openFirewall = true;

      settings = {
        global = {
          "guest account" = "myuser";
          "map to guest" = "Bad User";
        };
        nas = {
          "path" = "/mnt/nas";
          "guest ok" = "yes";
          "read only" = "no";
        };
        homelab = {
          "path" = "/mnt/homelab";
          "read only" = "no";
          "valid users" = "homelab";
          "public" = "no";
          "writable" = "yes";
          "browsable" = "yes";
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

    services.adguardhome = {
      enable = true;
      settings = {
        dns = {
          upstream_dns = [
            "8.8.8.8"
          ];
        };
        filtering = {
          protection_enabled = true;
          filtering_enabled = true;

          parental_enabled = false;  # Parental control-based DNS requests filtering.
          safe_search = {
            enabled = false;  # Enforcing "Safe search" option for search engines, when possible.
          };
        };
        # The following notation uses map
        # to not have to manually create {enabled = true; url = "";} for every filter
        # This is, however, fully optional
        filters = map(url: { enabled = true; url = url; }) [
          "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"  # The Big List of Hacked Malware Web Sites
          "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"  # malicious url blocklist
          "https://adguardteam.github.io/HostlistsRegistry/assets/filter_51.txt"
          "https://adguardteam.github.io/HostlistsRegistry/assets/filter_27.txt"
        ];
      };
    };
  };
}
