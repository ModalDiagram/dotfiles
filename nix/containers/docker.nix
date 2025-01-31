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

  systemd.services."backup_ghostfolio" = {
    path = [ pkgs.curl ];
    script = ''
      curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjA4ZmZmMjQxLWUwYTEtNGQ2My1iMWI5LTBlOGQyMjUyMzRmYiIsImlhdCI6MTczODM2MTMyMCwiZXhwIjoxNzUzOTEzMzIwfQ.tB2HjC5KTj9g4XXoGcYWc544NvVYvj_Az6jZwDBEMmE" https://stocks.sanfio.eu/api/v1/export > /mnt/homelab/backup/ghostfolio/backup.json
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "homelab";
    };
  };
}
