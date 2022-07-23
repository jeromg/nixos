{ config, pkgs, ... }:

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
  home.packages = with pkgs; [ 
    git
    gh
    thunderbird
    htop
    killall
    glances
    ];
}
