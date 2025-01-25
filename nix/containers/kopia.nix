{ pkgs, ... }: {
  sops.secrets.kopia_password = { sopsFile = ../secrets/containers.json; format = "json"; };

  containers.kopia = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.14";

    bindMounts = {
      "/run/secrets/kopia_password" = { hostPath = "/run/secrets/kopia_password"; };
    };
    config = { config, lib, ... }: {
      nixpkgs.pkgs = pkgs;
      system.stateVersion = "24.05";

      environment.etc."kopia_password" = {
        source = "/run/secrets/kopia_password";
        mode = "0400";
        user = "kopia";
      };

      environment.systemPackages = [ pkgs.kopia pkgs.rclone ];

      services.resolved.enable = true;

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 51515 ];
      };
      networking.useHostResolvConf = lib.mkForce false;

      users.users.kopia = {
        uid = 1555;
        isNormalUser = true;
        hashedPassword = "$y$j9T$Q.HD.crPHZVbigguUI.GV1$PTyklFYrHy/oQn/Bl.uEvyuXFqAVzy7qxq.mY7SH3B9";
      };

      systemd.timers."backup_ext" = {
        wantedBy = [ "timers.target" ];
          timerConfig = {
            Persistent = true;
            OnCalendar = "*-*-* 4:00:00";
            Unit = "backup_ext.service";
          };
      };

      systemd.services."backup_ext" = {
        path = [ pkgs.rclone ];
        script = ''
          ${pkgs.kopia}/bin/kopia repo sync-to rclone --remote-path=onedrive:repo1
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "kopia";
        };
      };

      systemd.services.kopia-server = {
        description = "Kopia Repository Server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        script = ''
          ${pkgs.kopia}/bin/kopia server start --address=192.168.100.14:51515 --tls-cert-file /home/kopia/newcert.cert --tls-key-file /home/kopia/newkey.key --server-control-username=kopia --server-control-password=$(cat /etc/kopia_password)
        '';

        serviceConfig = {
          ExecStop = "${pkgs.kopia}/bin/kopia server shutdown --address=192.168.100.14:51515";
          Restart = "always";
          User = "kopia";
        };
      };
    };
  };
}
