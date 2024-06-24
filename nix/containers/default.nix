{ ... }:
{
  imports = [
    ./paperless.nix
    ./nextcloud.nix
    ./hass.nix
  ];

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
        extraConfig = ''
          proxy_pass http://192.168.100.13:28981/paper;
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
  };


}
