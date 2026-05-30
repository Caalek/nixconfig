{
  description = "NixOS configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };
  };

  outputs = { nixpkgs, home-manager, llm-agents, ... }:
    let
      system = "x86_64-linux";
      opencode = llm-agents.packages.${system}.opencode;
      pkgs = nixpkgs.legacyPackages.${system}.extend (final: prev: {
        inherit opencode;
        terraform-bin = prev.stdenv.mkDerivation rec {
          pname = "terraform";
          version = "1.14.8";
          src = prev.fetchzip {
            url = "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_amd64.zip";
            hash = "sha256-UtvobU47BSkZLJOHZ61pLIFyBb9n7w9t0wS03GR41vg=";
            stripRoot = false;
          };
          installPhase = "install -Dm755 terraform $out/bin/terraform";
          meta.platforms = prev.lib.platforms.linux;
        };
      });
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.user = import ./home.nix;

            nixpkgs.overlays = [ (final: prev: {
              inherit opencode;
              terraform-bin = prev.stdenv.mkDerivation rec {
                pname = "terraform";
                version = "1.14.8";
                src = prev.fetchzip {
                  url = "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_amd64.zip";
                  hash = "sha256-UtvobU47BSkZLJOHZ61pLIFyBb9n7w9t0wS03GR41vg=";
                  stripRoot = false;
                };
                installPhase = "install -Dm755 terraform $out/bin/terraform";
                meta.platforms = prev.lib.platforms.linux;
              };
            }) ];
          }
        ];
      };

      homeConfigurations.user = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
}
