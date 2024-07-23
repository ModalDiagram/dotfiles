{ ... }: {
  containers.kopia = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.14";

    config = { config, pkgs, lib, ... }: {
      system.stateVersion = "24.05";

      environment.systemPackages = [ pkgs.kopia pkgs.rclone ];

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 51515 ];
      };
      users.users.kopia = {
        uid = 1555;
        isNormalUser = true;
        hashedPassword = "$y$j9T$Q.HD.crPHZVbigguUI.GV1$PTyklFYrHy/oQn/Bl.uEvyuXFqAVzy7qxq.mY7SH3B9";
      };

      systemd.services.kopia-server = {
        description = "Kopia Repository Server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          ExecStart = "${pkgs.kopia}/bin/kopia server start --address=192.168.100.14:51515 --tls-cert-file /home/kopia/newcert.cert --tls-key-file /home/kopia/newkey.key";
          ExecStop = "${pkgs.kopia}/bin/kopia server shutdown --address=192.168.100.14:51515";
          Restart = "always";
          User = "kopia";
        };
      };
    };
  };
}
