#!/bin/sh

disk=/dev/sda

parted "$disk" -- mklabel gpt
parted "$disk" -- mkpart primary 512MiB -8GiB
parted "$disk" -- mkpart primary linux-swap -8GiB 100%
parted "$disk" -- mkpart ESP fat32 1MiB 512MiB
parted "$disk" -- set 3 esp on
mkswap -L swap "${disk}2"
swapon /dev/sda2
mkfs.fat -F 32 -n EFI -i e02c7a1a "${disk}3"

zpool create \
  -o ashift=12 \
  -o autotrim=on \
  -R /mnt \
  -O canmount=off \
  -O mountpoint=none \
  -O acltype=posixacl \
  -O compression=zstd \
  -O dnodesize=auto \
  -O normalization=formD \
  -O relatime=on \
  -O xattr=sa \
  -O encryption=aes-256-gcm \
  -O keylocation=prompt \
  -O keyformat=passphrase \
  rpool /dev/sda1

zfs create -p -o mountpoint=legacy rpool/local/root
zfs snapshot rpool/local/root@blank

mount -t zfs rpool/local/root /mnt
mkdir /mnt/boot
mount /dev/sda3 /mnt/boot
zfs create -p -o mountpoint=legacy rpool/local/nix
mkdir /mnt/nix
mount -t zfs rpool/local/nix /mnt/nix
zfs create -p -o mountpoint=legacy rpool/safe/home
mkdir /mnt/home
mount -t zfs rpool/safe/home /mnt/home
zfs create -p -o mountpoint=legacy rpool/safe/persist
mkdir /mnt/persist
mount -t zfs rpool/safe/persist /mnt/persist

nix-env -iA nixos.git
nix flake update
git clone https://github.com/jeromg/nixos /mnt/etc/nixos

cd /mnt/etc/nixos

nixos-install --flake .#telperion

