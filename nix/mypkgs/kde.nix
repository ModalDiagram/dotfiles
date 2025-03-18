{ config, pkgs, lib, inputs, ... }: {
  config = {
    services.desktopManager.plasma6.enable = true;
  };
}
