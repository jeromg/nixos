# NixOS installation scripts (work in progress)

This is my own attempt at building NixOS from scratch. This provides the bare minimum at the moment, I'll be working on it before I can install NixOS as (hopefully) my daily driver.

This repo includes:
  - a partitioning script using ZFS with native encryption
  - a NixOS confiration (flake-based) for a HyperV guest VM using home-manager
  - it provides an almost stateless installation as per the excellent article by Graham Christensen [Erase your darlings](https://grahamc.com/blog/erase-your-darlings)

## Objective
- Setup a brand new NixOS VM under HyperV in a (semi-)automated way
  - Create a new Generation 2 VM (UEFI)
  - Don't forget to disable Secure Boot in VM settings under Security
  - Boot from an unstable NixOS ISO
```
$ sudo su
# curl -O https://raw.githubusercontent/jeromg/nixos/main/auto-install.sh
# chmod +x auto-install.sh
[You may want to change the user and the machine name in configuration.nix and in auto-install.sh for the flake profile to be built]
# ./auto-install.sh
...
[Enter ZSH passphrase]
...
[Enter root password]

# reboot
```
- You now have a functional VM (XFCE)
- Once logged in
```
$ passwd (change default password)
$ mkdir ~/.setup
$ sudo mv /etc/nixos/* ~/.setup/
$ cd ~/.setup
$ sudo chown [username]:users *
$ nix flake update
$ sudo nixos-rebuild switch --flake .#[profile]

```
## Credits
- [Matthias Benaets](https://github.com/MatthiasBenaets/nixos-config) and his incredible [tutorial video](https://www.youtube.com/watch?v=AGVXJ-TIv3Y)
- [Tristan Maat](https://github.com/TLATER/dotfiles)

## Todo
- Error catching and friendly error messages in auto-install.sh
- Add some parameters for username, machine name

