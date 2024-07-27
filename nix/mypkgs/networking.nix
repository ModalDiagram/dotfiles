{ config, lib, ... }: {
  options.mypkgs.networking = {
    enable = lib.mkOption {
      description = "enable network functionality";
      type = lib.types.bool;
      default = false;
    };
    interface = lib.mkOption {
      description = "interface to use: wpa_supplicant, iwd";
      type = lib.types.str;
      default = "";
    };
    bluetooth.enable = lib.mkOption {
      description = "enable bluetooth";
      type = lib.types.bool;
      default = true;
    };
  };
  config = lib.mkIf (config.mypkgs.networking.enable == true) (lib.mkMerge [
    (lib.mkIf (config.mypkgs.networking.interface == "wpa_supplicant") {
      networking.networkmanager.enable = true;
      networking.networkmanager.wifi.powersave = true;
    })
    (lib.mkIf (config.mypkgs.networking.interface == "iwd") {
      # networking.networkmanager.enable = true;
      networking.wireless.iwd = {
        enable = true;
        settings = {
          Network = {
            EnableIPv6 = false;
          };
        };
      };
      # networking.networkmanager.wifi.backend = "iwd";
    })
    {
      # to connect to WLUCTSTUD
      # nmcli connection add type wifi con-name "WLUCTSTUD1" ifname wlp1s0 ssid "WLUCTSTUD" wifi-sec.key-mgmt wpa-eap 802-1x.identity "frtsdr01p21f209u@studium.unict.it" 802-1x.password <PASSWORD> 802-1x.system-ca-certs no 802-1x.eap "peap" 802-1x.phase2-auth mschapv2
      networking.networkmanager.ensureProfiles.environmentFiles = [ 
        "/run/secrets/network.env"
      ];
      networking.networkmanager.ensureProfiles.profiles = {
        hotspot = {
          connection = {
            id = "POCO F5";
            type = "wifi";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "POCO F5";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = "$PSK_POCO";
          };
        };
        uni_wifi = {
          connection = {
            id = "WLUCTSTUD";
            type = "wifi";
            autoconnect = false;
          };
          wifi = {
            mode = "infrastructure";
            ssid = "WLUCTSTUD";
          };
          wifi-security = {
            key-mgmt = "wpa-eap";
          };
          "802-1x" = {
            eap = "peap;";
            identity = "$UNI_IDENTITY";
            password = "$UNI_PASSWORD";
            phase2-auth = "mschapv2";
          };
        };
        militello_wifi = {
          connection = {
            id = "Vodafone-C00510203";
            type = "wifi";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "Vodafone-C00510203";
            band="bg";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = "$MILITELLO_WIFI_PASSWORD";
          };
        };
        piana_wifi = {
          connection = {
            id = "$PIANA_WIFI_ID";
            type = "wifi";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "$PIANA_WIFI_ID";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = "$PIANA_WIFI_PASSWORD";
          };
        };
      };
      # networking.wireless.networks.Vodafone-C00510203.pskRaw = "c0e26f412b3077cc6e3179fac7ebecd31902c2cf541a73af168b47e504b13b5a";
      # networking.wireless.networks."POCO F5".pskRaw = "4345acaf2e98e22e5ca125a3606a1069a647754c16d3a31a84551b7d0cc36412";
      # networking.wireless.networks."Home&Life SuperWiFi-1E71".pskRaw = "b4d33351ac5e31987712b429f443eea91498c9651879daacd6f816612f564969";
      networking.firewall.enable = true;
      networking.firewall.extraCommands = ''
        iptables -A INPUT -p tcp -i wlan0 --dport 5000:5002 -j ACCEPT
        iptables -A INPUT -p tcp -i tailscale0 --dport 5000:5002 -j ACCEPT
      '';
      networking.firewall.allowedTCPPorts = [ 80 443 8554 ];
    }
    (lib.mkIf (config.mypkgs.networking.bluetooth.enable) {
      hardware.bluetooth.enable = true; # enables support for Bluetooth
    })
  ]);
}
