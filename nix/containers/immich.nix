{ pkgs, ... }: {
  containers.immich = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.16";

    config = { config, lib, ... }: {
      nixpkgs.pkgs = pkgs;

      environment.systemPackages = with pkgs; [
        kopia
        exiftool
      ];

      users.users.kopia = {
        group = "immich";
        isNormalUser = true;
      };

      services.immich = {
        enable = true;
        port = 2283;
        host = "0.0.0.0";
      };
      system.stateVersion = "24.05";

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 2283 ];
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;

    };
  };
}
