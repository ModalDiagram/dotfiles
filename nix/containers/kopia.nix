{ config, ... }: let ipaddr = config.containers1.ipaddr; in {
  containers.kopia = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.14";

    config = { config, pkgs, lib, ... }: {
      system.stateVersion = "24.05";

      environment.systemPackages = [ pkgs.kopia ];

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 51515 ];
      };
      users.users.kopia = {
        uid = 1555;
        isNormalUser = true;
        hashedPassword = "$y$j9T$Q.HD.crPHZVbigguUI.GV1$PTyklFYrHy/oQn/Bl.uEvyuXFqAVzy7qxq.mY7SH3B9";
      };
    };
  };
}
