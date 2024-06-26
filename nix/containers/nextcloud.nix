{ config, ... }: let ipaddr = config.containers1.ipaddr; in {
  containers.nextcloud = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    bindMounts = {
      "/backup_repo" = { hostPath = "/home/kopia/backups"; isReadOnly = false; };
    };

    config = { config, pkgs, lib, ... }: {
      environment.systemPackages = [ pkgs.kopia pkgs.nextcloud29 ];
      users.users.kopia = {
        uid = 1555;
        isNormalUser = true;
        group = "users";
        hashedPassword = "$y$j9T$Q.HD.crPHZVbigguUI.GV1$PTyklFYrHy/oQn/Bl.uEvyuXFqAVzy7qxq.mY7SH3B9";
        extraGroups = [ "nextcloud" ];
      };

#       systemd.timers."backup_nextcloud" = {
#         wantedBy = [ "timers.target" ];
#           timerConfig = {
#         OnBootSec = "1m";
#         OnUnitActiveSec = "1m";
#             # Persistent = true;
#             # OnCalendar = "*-*-* 2:00:00";
#             Unit = "backup_nextcloud.service";
#           };
#       };

#       systemd.services."backup_nextcloud" = {
#         script = ''
#           ${pkgs.bash}/bin/bash -c '
#             kopia snapshot create /var/lib/nextcloud/data
#           '
#         '';
#         serviceConfig = {
#           Type = "oneshot";
#           User = "kopia";
#         };
#         requires = [ "dump_sql.service" ];
#         after = [ "dump_sql.service" ];
#       };

#       systemd.services."dump_sql" = {
#         script = ''
#           ${pkgs.bash}/bin/bash -c '

#           '
#         '';
#         serviceConfig = {
#           Type = "oneshot";
#           User = "nextcloud";
#         };
#       };


      systemd.services."nextcloud-setup" = {
        requires = ["postgresql.service"];
        after = ["postgresql.service"];
      };

      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud29;
        hostName = "${ipaddr}";

        # Database options
        config = {
          dbtype = "pgsql";
          dbuser = "nextcloud";
          dbhost = "/run/postgresql";
          dbname = "nextcloud";
          dbpassFile = "${pkgs.writeText "dbpass" "test123"}";
        };

        settings = let
            prot = "https"; # or https
            host = "${ipaddr}";
            dir = "/nextcloud";
          in {
            overwriteprotocol = prot;
            overwritehost = host;
            overwritewebroot = dir;
            overwrite.cli.url = "${prot}://${host}${dir}/";
            htaccess.RewriteBase = dir;
          };
        config.adminpassFile = "${pkgs.writeText "adminpass" "test123"}"; # DON'T DO THIS IN PRODUCTION - the password file will be world-readable in the Nix Store!

        extraAppsEnable = true;
        extraApps = {
          inherit (config.services.nextcloud.package.packages.apps) calendar tasks;
          memories = pkgs.fetchNextcloudApp {
              sha256 = "sha256-DJPskJ4rTECTaO1XJFeOD1EfA3TQR4YXqG+NIti0UPE=";
              url = "https://github.com/pulsejet/memories/releases/download/v7.3.1/memories.tar.gz";
              license = "gpl3";
          };
          maps = pkgs.fetchNextcloudApp {
              sha256 = "sha256-LOQBR3LM7artg9PyD8JFVO/FKVnitALDulXelvPQFb8=";
              url = "https://github.com/nextcloud/maps/releases/download/v1.4.0/maps-1.4.0.tar.gz";
              license = "gpl3";
          };
        };
      };

      services.postgresql = {
        enable = true;

        # Ensure the database, user, and permissions always exist
        ensureDatabases = [ "nextcloud" ];
        ensureUsers = [
          { name = "nextcloud";
            ensureDBOwnership = true;
          }
        ];

        # authentication = ''
        #   local   all   nextcloud   md5
        # '';
      };


      system.stateVersion = "24.05";

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 80 ];
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;

    };
  };
}
