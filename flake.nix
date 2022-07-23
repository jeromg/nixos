{
  description = "My Flake setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }:
  let 
    impermanence = builtins.fetchTarBall "https://github.com/nix-community/impermanence/archive/master.tar.gz";
    user = "jerome";
    location = "$HOME/.setup";
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

      nixosConfigurations = (
        import ./hosts {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs home-manager user location;
        }
      );
    };
}
