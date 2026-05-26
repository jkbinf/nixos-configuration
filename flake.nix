{
  description = "Jakub's NixOS System";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-shell = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, noctalia-shell, ... }:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [

        ./configuration.nix

        home-manager.nixosModules.home-manager

        {
          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];

          environment.systemPackages =
            [
              pkgs.git
              pkgs.curl
              pkgs.wget
              pkgs.fastfetch
              pkgs.neovim

              # Noctalia package
              noctalia-shell.packages.${system}.default
            ];

          users.users.jakub = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" ];
          };

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.jakub = { pkgs, ... }: {
            home.username = "jakub";
            home.homeDirectory = "/home/jakub";

            home.stateVersion = "25.05";

            programs.git.enable = true;
            programs.bash.enable = true;

            home.packages = with pkgs; [
              firefox
              discord
              vscode
            ];

            programs.home-manager.enable = true;
          };
        }
      ];
    };
  };
}
