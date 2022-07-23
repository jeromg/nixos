{ config, pkgs, ... }:

  home.packages = with pkgs; [ 
    git
    gh
    thunderbird
    htop
    killall
    glances
    ];
}
