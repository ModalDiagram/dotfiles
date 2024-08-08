{ ... }: {
  containers.kavita = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.15";

    bindMounts.nextcloud = {
      hostPath = "/var/lib/nixos-containers/nextcloud/var/lib/nextcloud/data/root/files/books";
      mountPoint = "/var/lib/kavita/nextcloud_library";
      isReadOnly = false;
    };
    config = { config, pkgs, lib, ... }: {
      system.stateVersion = "24.05";


      users.groups.nextcloud = {
        gid = 999;
        members = [ "kavita" ];
      };

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 5000 ];
      };

      services.kavita = {
        enable = true;
        tokenKeyFile = "/var/lib/kavita/tokenkey.txt";
        settings = {
          IpAddresses = "0.0.0.0";
        };
      };
    };
  };
}
