# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, pkgs, user, ... }:
  let 
    src = {
      url = "https://github.com/nix-community/impermanence/archive/master.tar.gz";
      sha256 = "0x7mwbqj1h3rym93hy1knxd33dzspmy5i7y1k930vg85yp3a1y8q";
      };
    impermanence = builtins.fetchTarball src;
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
  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
    };
    timeout = 15;
  };

  networking = {
    hostName = "melian"; # Define your hostname.
    hostId = "01020304";
    interfaces.wlp2s0.useDHCP = true;
    networkmanager.enable = true;
  };

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.${user} = {
     isNormalUser = true;
     initialPassword = "test";
     extraGroups = [ "wheel" "networkmanager"]; # Enable ‘sudo’ for the user.
     openssh.authorizedKeys.keys = [
       "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRh/o9OAy/+zFCQN4b/v5zReUdMSS+Fq5PpH/HIXQ9SQZEiJoZZsd3tjrBDtctgjuP/WFHhGK5MwMJddiwhQb8CVpB0uU06OR0Lw94a+eTw7Z7K/csP5G1fOaPggx+2LQ0DFn2kII3Vx0XQ1tMzpGbgdr1D9+uGhOcWctX17ynYJz77bhj8E3R1B1Z4GtQcBMqnmEgcLcUsTHlJaR3/TgmWgFuXBxyV+ZFytTDaUJ2dkAzmyZkFropIuiKEPEdAysJSp40tnc1Kkoz9x9Sv9rfLYQ4GdcFQ/nGLD1Hd8H/1aOryxt3kBmpp2SMkWIsj/3/6VGreWQmc1IQ/GaBAH10aP2K6BsxTSqdpkBuXAeTUAlfcC5ba1eWhiOXMYio0yoG7EBtTG9lIohaSVyajErlmlmJKUOs0hHSfhb9AkTLCqJkro7a/5yYmcSYA55w2SYKr7GsxiU2/SG4HqiTgWm5Eo4lSRHzmRvTwRFjlWdowMNRKsUPQKKARFAwlU7Oiv9M46kP5bbzmNCMqqg+eiVqvLgquKYhRXddhmCUnnP+FmZCdDePH35grsEbUpzt4y+rgghPlfL8IEanbg7Cy2KauNy+Le0eQFjAXx/5cXWeL+Creogfa0plafg+R6yBNToUhzdkszirt8KPjtW4+8PGafgDOejXCs4HBQT9BhDiyQ== nixos-windows"
     ];
   };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      vim
      wget
    ];
  };

  services.zfs = {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
    };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
  };

  system.autoUpgrade = {
    enable = true;
    channel = "https://nixos.org/channels/nixos-unstable";
    dates = "weekly";
  };

  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 10d";
    };
  };

  nix = {
    package=pkgs.nixFlakes;
    extraOptions = "extra-experimental-features = nix-command flakes";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}

