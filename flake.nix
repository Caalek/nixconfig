{
  description = "NixOS configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };
  };

  outputs = { nixpkgs, home-manager, llm-agents, ... }:
    let
      system = "x86_64-linux";
      username = let u = builtins.getEnv "USER"; in if u != "" && u != "root" then u else "vm";
      opencode = llm-agents.packages.${system}.opencode;
      pkgs = nixpkgs.legacyPackages.${system}.extend (final: prev: {
        inherit opencode;
      });
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit username; };
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = import ./home.nix;

            nixpkgs.overlays = [ (final: prev: { inherit opencode; }) ];
          }
        ];
      };

      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ({ pkgs, ... }: {
            home.username = username;
            home.homeDirectory = "/home/${username}";
          })
          ./home.nix
        ];
      };
    };
}
