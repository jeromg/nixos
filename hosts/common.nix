{ config, lib, pkgs, user, ... }:

{
  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = with pkgs; [
      btop
      pfetch
      feh
      firefox
      brave
      pcmanfm
      rsync
      rclone
      unzip
      unrar
    ];
    stateVersion = "22.11";
  };   
  programs = {
    home-manager.enable = true;
  };
}
