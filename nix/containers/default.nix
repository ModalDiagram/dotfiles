{ config, lib, pkgs, ... }:
{
  imports = [
    ./paperless.nix
    ./nextcloud.nix
    ./hass.nix
    ./kopia.nix
  ];

  options.containers1 = {
    interface = lib.mkOption {
      description = "interface to use: something like wlp1s0";
      type = lib.types.str;
    };
    ipaddr = lib.mkOption {
      description = "ip address where containers will be served";
      type = lib.types.str;
    };
  };

  config = {

    # Wireguard setup
    # TODO: remove dependence on the current ipaddr of the wireless network
    environment.systemPackages = [ pkgs.wireguard-tools ];
    networking.wireguard.interfaces = {
      wg0 = {
        ips = [ "10.0.0.1/24" ]; # The IP address for the server on the VPN
        listenPort = 51820;

        privateKeyFile = "/run/secrets/homelab_private_wireguard";
        peers = [
          {
            publicKey = "xEm6HUXJVJmhL5qQGycHewTLfmuyWQzIlI79XAV4vC4=";
            allowedIPs = [ "10.0.0.2/32" ]; # The IP address for the client on the VPN
          }
          {
            publicKey = "seCh6h/tgjowWqfpHzJrqdC1yyzshssuIBjkUkbr4kY=";
            allowedIPs = [ "10.0.0.3/32" ]; # The IP address for the client on the VPN
          }
        ];
      };
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
        allowedTCPPorts = [ 51515 ];
        extraCommands = ''
            ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -d 10.0.0.5/24 -p tcp --dport 51515 -j DNAT --to-destination 192.168.1.14:51515
            ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -d 10.0.0.5/24 -j DNAT --to-destination 192.168.1.5
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -j MASQUERADE
        '';
      };
    };

    users.users.nginx.extraGroups = [ "acme" ];
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "web@saf.slmail.me";
        dnsProvider = "cloudflare";
        environmentFile = /home/homelab/cloudflare_creds.txt;
      };
    };
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts."www.sanfio.eu" = {
        forceSSL = true;
        enableACME = true;
        # extraConfig = ''
        #   client_max_body_size 1G;
        # '';
        locations."/" = {
          proxyWebsockets = true;
          proxyPass = "http://192.168.100.12:8123";
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

    # services.nginx = {
    #   enable = true;
    #   recommendedProxySettings = true;
    #   virtualHosts."sanfio.eu" = {
    #     # forceSSL = true;
    #     # enableACME = true;
    #     # acmeRoot = null;
    #     extraConfig = ''
    #       proxy_buffering off;
    #       client_max_body_size 1G;
    #     '';
    #     locations."/.well-known/acme-challenge" = {
    #       extraConfig = ''
    #         proxy_pass http://127.0.0.1:81;
    #         proxy_set_header Host $host;
    #       '';
    #     };

    #     locations."^~ /.well-known" = {
    #       priority = 9000;
    #       extraConfig = ''
    #         absolute_redirect off;
    #         location ~ ^/\\.well-known/(?:carddav|caldav)$ {
    #           return 301 /nextcloud/remote.php/dav;
    #         }
    #         location ~ ^/\\.well-known/host-meta(?:\\.json)?$ {
    #           return 301 /nextcloud/public.php?service=host-meta-json;
    #         }
    #         location ~ ^/\\.well-known/(?!acme-challenge|pki-validation) {
    #           return 301 /nextcloud/index.php$request_uri;
    #         }
    #         try_files $uri $uri/ =404;
    #       '';
    #     };
    #     locations."/nextcloud/" = {
    #       priority = 9999;
    #       extraConfig = ''
    #         proxy_set_header X-Real-IP $remote_addr;
    #         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #         proxy_set_header X-NginX-Proxy true;
    #         proxy_set_header X-Forwarded-Proto http;
    #         proxy_pass http://192.168.100.11:80/; # tailing / is important!
    #         proxy_set_header Host $host;
    #         proxy_cache_bypass $http_upgrade;
    #         proxy_redirect off;
    #       '';
    #     };
    #     locations."/" = {
    #       proxyWebsockets = true;
    #       proxyPass = "http://192.168.100.12:8123";
    #     };
    #     locations."/red" = {
    #       proxyWebsockets = true;
    #       proxyPass = "http://192.168.100.12:1880";
    #     };
    #     locations."/paper" = {
    #       extraConfig = ''
    #         proxy_pass http://192.168.100.13:28981/paper;
    #         proxy_http_version 1.1;
    #         proxy_set_header Upgrade $http_upgrade;
    #         proxy_set_header Connection "upgrade";

    #         proxy_redirect off;
    #         proxy_set_header Host $host;
    #         proxy_set_header X-Real-IP $remote_addr;
    #         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #         proxy_set_header X-Forwarded-Host $server_name;
    #         add_header Referrer-Policy "strict-origin-when-cross-origin";
    #       '';
    #     };
    #   };
    # };
  };
}
