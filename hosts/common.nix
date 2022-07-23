{ config, lib, pkgs, user, ... }:

{
  let 
    impermanence = builtins.fetchTarBall "https://github.com/nix-community/impermanence/archive/master.tar.gz";
  in
  {
    imports = [ "${impermanence}/nixos.nix" ];
    environment.persistence."/persist" = {
        directories = [
          "/var/lib/bluetooth"
          "/etc/NetworkManager"
          "/var/log"
          "/var/lib"
        ];
      };
   }

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
