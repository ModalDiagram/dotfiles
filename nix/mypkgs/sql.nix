{ config, pkgs, lib, ... }: {
  options.mypkgs.sql = {
    enable = lib.mkOption {
      description = "Enable sql service with mariadb";
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf (config.mypkgs.sql.enable) {
    services.mysql.enable = true;
    services.mysql.package = pkgs.mariadb;
    systemd.services.mysql.wantedBy = lib.mkForce [];
  };
}
