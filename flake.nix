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
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, llm-agents, agenix, ... }:
    let
      system = "x86_64-linux";
      opencode = llm-agents.packages.${system}.opencode;
      pkgs = nixpkgs.legacyPackages.${system}.extend (final: prev: {
        inherit opencode;
      });
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          agenix.nixosModules.age
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.vm = import ./home.nix;

            nixpkgs.overlays = [ (final: prev: { inherit opencode; }) ];
          }
        ];
      };

      homeConfigurations.vm = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
}
