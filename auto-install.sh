#!/bin/sh

# Define install disk
disk=/dev/sda

# Create new GPT
parted "$disk" -- mklabel gpt

# Create main partition, leaving 512MiB at the beginning 
# for EFI boot and 8GiB at the end for Swap
parted "$disk" -- mkpart primary 512MiB -8GiB

# Create swap partition
parted "$disk" -- mkpart primary linux-swap -8GiB 100%

# Create boot partition (ESP and FAT32)
parted "$disk" -- mkpart ESP fat32 1MiB 512MiB
parted "$disk" -- set 3 esp on

# Make swap partition
mkswap -L swap "${disk}2"
swapon /dev/sda2

# Format boot partition and force UUID to avoid modification of hardware config
mkfs.fat -F 32 -n EFI -i e02c7a1a "${disk}3"

# Create encrypted main ZFS pool
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

# Create root bool and make a blank snapshot (for root reset)
zfs create -p -o mountpoint=legacy rpool/local/root
zfs snapshot rpool/local/root@blank

# Mount root pool
mount -t zfs rpool/local/root /mnt

# Mount boot partition
mkdir /mnt/boot
mount /dev/sda3 /mnt/boot

# Create and mount nix pool
zfs create -p -o mountpoint=legacy rpool/local/nix
mkdir /mnt/nix
mount -t zfs rpool/local/nix /mnt/nix

# Create and mount home pool
zfs create -p -o mountpoint=legacy rpool/safe/home
mkdir /mnt/home
mount -t zfs rpool/safe/home /mnt/home

# Create persist pool to allow for root reset at boot time
zfs create -p -o mountpoint=legacy rpool/safe/persist
mkdir /mnt/persist
mount -t zfs rpool/safe/persist /mnt/persist

# Install git and clone repo
nix-env -iA nixos.git
git clone https://github.com/jeromg/nixos /mnt/etc/nixos

# Install OS
cd /mnt/etc/nixos
nixos-install --flake .#telperion

