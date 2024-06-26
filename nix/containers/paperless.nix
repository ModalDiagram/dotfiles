{ config, ... }: let ipaddr = config.containers1.ipaddr; in {
  containers.paperless = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.13";
    ephemeral = true;
    # bindMounts = {
    #   "/var/lib/paperless" = { hostPath = "/home/sserver/backup_dir/paperless_data"; isReadOnly = false; };
    # };
    config = { config, pkgs, lib, ... }: {
      system.stateVersion = "24.05";

      services.paperless = {
        enable = true;
        passwordFile = "/run/secrets/paperless_password";
        address = "0.0.0.0";
        settings = {
          PAPERLESS_URL = "https://" + "${ipaddr}";
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
}
