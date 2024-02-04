{ ... }: {
  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };


  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "it";
    xkb.variant = "";
  };

  # Configure console keymap
  console.keyMap = "it";

  # Create the group i2c which is needed for external monitor brightness
  users.groups.i2c = {};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sandro0198 = {
    isNormalUser = true;
    description = "Sandro";
    extraGroups = [ "networkmanager" "wheel" "input" "i2c" ];
  };
}
