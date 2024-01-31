{ pkgs, config, ... }: {
  # To enable IWD with networkmanager --------
  # networking.wireless.iwd = {
  #   enable = true;
  #   settings = {
  #     Settings = {
  #       AutoConnect = true;
  #     };
  #   };
  # };
  # networking.networkmanager.enable = true;
  # networking.networkmanager.wifi.backend = "iwd";
  # ---------
  # To enable wpa_supplicant without networkmanager
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.wireless.userControlled.enable = true;
  networking.wireless.networks.Vodafone-C00510203.pskRaw = "c0e26f412b3077cc6e3179fac7ebecd31902c2cf541a73af168b47e504b13b5a";
  networking.wireless.networks."POCO F5".pskRaw = "4345acaf2e98e22e5ca125a3606a1069a647754c16d3a31a84551b7d0cc36412";
  networking.wireless.networks."Home&Life SuperWiFi-1E71".pskRaw = "b4d33351ac5e31987712b429f443eea91498c9651879daacd6f816612f564969";
  environment.systemPackages = with pkgs; [
    wpa_supplicant_gui
  ];
  home-manager.users.${config.main-user} = {
    home.shellAliases = {
      nmtui = "wpa_gui";
    };
  };
  # ---------

  # Host settings
  networking.hostName = "nixos"; # Define your hostname.
  networking.firewall.enable = true;
  networking.firewall.extraCommands = ''
    iptables -A INPUT -p tcp -i wlan0 --dport 5000:5002 -j ACCEPT
    iptables -A INPUT -p tcp -i tailscale0 --dport 5000:5002 -j ACCEPT
  '';
}
