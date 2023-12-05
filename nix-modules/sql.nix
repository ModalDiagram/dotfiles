{ pkgs, lib, ... }: {
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;
  systemd.services.mysql.wantedBy = lib.mkForce [];
}
