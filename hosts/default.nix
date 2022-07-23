{ lib, inputs, nixpkgs, home-manager, user, location, ...}:

let
  system="x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  lib = nixpkgs.lib;

in
{
  telperion = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit pkgs inputs user location; };
    modules = [
      ./hyperv-vm/configuration.nix
      ./hyperv-vm/hardware.nix
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {inherit user;};
        home-manager.users.${user} = {
          imports = [(import ./common.nix)] ++ [(import ./hyperv-vm/home.nix)];
        };
      }
    ];
  };
  melian = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit pkgs inputs user location; };
    modules = [
      ./mini/configuration.nix
      ./mini/hardware.nix
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {inherit user;};
        home-manager.users.${user} = {
          imports = [(import ./common.nix)] ++ [(import ./mini/home.nix)];
        };
      }
    ];
  };
}
