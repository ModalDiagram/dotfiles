{ config, lib, ... }: {
  options.mypkgs.networking = {
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
  config = lib.mkMerge [
    (lib.mkIf (config.mypkgs.networking.interface == "wpa_supplicant") {
      networking.networkmanager.enable = true;
    })
    (lib.mkIf (config.mypkgs.networking.interface == "iwd") {
      networking.wireless.iwd = {
        enable = true;
        settings = {
          Settings = {
            AutoConnect = true;
          };
        };
      };
      networking.networkmanager.wifi.backend = "iwd";
    })
    {
      networking.wireless.networks.Vodafone-C00510203.pskRaw = "c0e26f412b3077cc6e3179fac7ebecd31902c2cf541a73af168b47e504b13b5a";
      networking.wireless.networks."POCO F5".pskRaw = "4345acaf2e98e22e5ca125a3606a1069a647754c16d3a31a84551b7d0cc36412";
      networking.wireless.networks."Home&Life SuperWiFi-1E71".pskRaw = "b4d33351ac5e31987712b429f443eea91498c9651879daacd6f816612f564969";
      networking.hostName = "nixos"; # Define your hostname.
      networking.firewall.enable = true;
      networking.firewall.extraCommands = ''
        iptables -A INPUT -p tcp -i wlan0 --dport 5000:5002 -j ACCEPT
        iptables -A INPUT -p tcp -i tailscale0 --dport 5000:5002 -j ACCEPT
      '';
    }
    (lib.mkIf (config.mypkgs.networking.bluetooth.enable) {
      hardware.bluetooth.enable = true; # enables support for Bluetooth
    })
  ];
}
