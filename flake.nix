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
      pi = llm-agents.packages.${system}.pi;
      pkgs = nixpkgs.legacyPackages.${system}.extend (final: prev: {
        inherit opencode pi;
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
        snicat = prev.buildGoModule rec {
          pname = "snicat";
          version = "0.0.2";
          src = prev.fetchFromGitHub {
            owner = "CTFd";
            repo = "snicat";
            rev = "${version}";
            hash = "sha256-BTNqSVLrAWodgOKd569RGJ5QWdFillUOkCaf/fojZV8=";
          };
          vendorHash = "sha256-f2fzJAnGRyfBgM2tNXOVurDdfdLzH7QbE8UQ3p4tShg=";
          meta = with prev.lib; {
            description = "TLS & SNI aware netcat";
            homepage = "https://github.com/CTFd/snicat";
            license = licenses.asl20;
            mainProgram = "snicat";
          };
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
              inherit opencode pi;
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
              snicat = prev.buildGoModule rec {
                pname = "snicat";
                version = "0.0.2";
                src = prev.fetchFromGitHub {
                  owner = "CTFd";
                  repo = "snicat";
                  rev = "${version}";
                  hash = "sha256-BTNqSVLrAWodgOKd569RGJ5QWdFillUOkCaf/fojZV8=";
                };
                vendorHash = "sha256-f2fzJAnGRyfBgM2tNXOVurDdfdLzH7QbE8UQ3p4tShg=";
                meta = with prev.lib; {
                  description = "TLS & SNI aware netcat";
                  homepage = "https://github.com/CTFd/snicat";
                  license = licenses.asl20;
                  mainProgram = "snicat";
                };
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
