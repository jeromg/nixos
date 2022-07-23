#!/bin/sh

# Define install disk
disk=/dev/sdb

# Define Machine name (used for Flake)
flake_machine="melian"

# Create new GPT
parted "$disk" -- mklabel gpt

# Create main partition, leaving 512MiB at the beginning 
# for EFI boot and 8GiB at the end for Swap
echo "Create main partition"
parted "$disk" -- mkpart primary 512MiB -12GiB

# Create swap partition
echo "Create swap partition"
parted "$disk" -- mkpart primary linux-swap -12GiB 100%

# Create boot partition (ESP and FAT32)
echo "Create boot partition"
parted "$disk" -- mkpart ESP fat32 1MiB 512MiB
parted "$disk" -- set 3 esp on

# Make swap partition
echo "Create make and activate swap partition"
mkswap -L swap "${disk}2"
swapon ${disk}2

# Format boot partition and force UUID to avoid modification of hardware config
echo "Format boot partition"
mkfs.fat -F 32 -n EFI "${disk}3"

# Create encrypted main ZFS pool
echo "Create ZFS main pool"
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
  rpool ${disk}1

# Create root bool and make a blank snapshot (for root reset)
echo "Create root pool and make initial snapshot"
zfs create -p -o mountpoint=legacy rpool/local/root
zfs snapshot rpool/local/root@blank

# Mount root pool
echo "Mount root pool"
mount -t zfs rpool/local/root /mnt

# Mount boot partition
echo "Mount boot pool"
mkdir /mnt/boot
mount ${disk}3 /mnt/boot

# Create and mount nix pool
echo "Create and mount nix pool"
zfs create -p -o mountpoint=legacy rpool/local/nix
mkdir /mnt/nix
mount -t zfs rpool/local/nix /mnt/nix

# Create and mount home pool
echo "Create and mount home pool"
zfs create -p -o mountpoint=legacy rpool/safe/home
mkdir /mnt/home
mount -t zfs rpool/safe/home /mnt/home

# Create persist pool to allow for root reset at boot time
echo "Create and mount persist pool"
zfs create -p -o mountpoint=legacy rpool/safe/persist
mkdir /mnt/persist
mount -t zfs rpool/safe/persist /mnt/persist

# Allow ZFS auto snapshots
zfs set com.sun:auto-snapshot=true rpool/safe/home
zfs set com.sun:auto-snapshot=true rpool/safe/persist

# Install git and clone repo
echo "Install git and clone repo"
nix-env -iA nixos.git
git clone https://github.com/jeromg/nixos /mnt/etc/nixos

# Install OS
echo "Install OS"
cd /mnt/etc/nixos
nixos-install --flake .#{flake_machine}

