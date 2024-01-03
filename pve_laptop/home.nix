{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sandro0198";
  home.homeDirectory = "/home/sandro0198";


  imports =
    [ # Include the results of the hardware scan.
      ../nix-modules/neovim.nix
      ../nix-modules/python.nix
    ];
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/nvim/".source = config.lib.file.mkOutOfStoreSymlink ../conf.d/nvim;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/sandro0198/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs.vim = {
    enable = true;
    # extraConfig = builtins.readFile vim/vimrc;
    settings = {
       relativenumber = true;
       number = true;
       expandtab = true;
       shiftwidth = 2;
       tabstop = 2;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
