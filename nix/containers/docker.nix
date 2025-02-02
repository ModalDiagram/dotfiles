{ pkgs, ... }: {
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  systemd.timers."backup_ghostfolio" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        Persistent = true;
        OnCalendar = "*-*-1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31 02:00:00";
        Unit = "backup_ghostfolio.service";
      };
  };

  sops.secrets.bearer_ghostfolio = { sopsFile = ../secrets/containers.json; format = "json"; owner = "homelab"; };

  systemd.services."backup_ghostfolio" = {
    path = [ pkgs.curl ];
    script = ''
      bearer_token=$(cat /run/secrets/bearer_ghostfolio)
      res=$(curl -H "Authorization: Bearer $bearer_token" https://stocks.sanfio.eu/api/v1/export)
      if [[ -n "$res" ]]; then
        if [[ "''${res:0:1}" == "{" ]]; then
          echo "$res" > /mnt/homelab/backup/ghostfolio/backup.json;
        fi
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "homelab";
    };
  };
}
