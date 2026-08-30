{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
#    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    templ.url = "github:a-h/templ";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpanel.url = "github:jas-singhfsu/hyprpanel";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    swww.url = "github:LGFae/swww";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    
    # Homebrew Taps
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    deskflow = {
	url = "github:deskflow/homebrew-tap";
	flake = false;
    };
    brief = {
	url = "github:graytonio/brief";
	flake = false;
    };
  };

  outputs = { nixpkgs, nix-darwin, home-manager, hyprland, hyprpanel, nur, nix-homebrew, homebrew-core, homebrew-cask, deskflow, brief, ... }@inputs:
  let
    mkHome = system: module: home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit inputs; };
      modules = [ module ];
    };
  in
  {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt;

    homeConfigurations."shell-linux"  = mkHome "x86_64-linux"   ./systems/shell/home.nix;
    homeConfigurations."shell-darwin" = mkHome "aarch64-darwin" ./systems/shell/home.nix;

    # Headless: the Coder workspace container. No GUI applications, and no
    # builtins.getEnv, so coder/Dockerfile activates it without --impure.
    homeConfigurations."headless-linux" = mkHome "x86_64-linux" ./systems/headless/home.nix;

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
      modules = [
        ./systems/nixos/configuration.nix
        nur.modules.nixos.default
        hyprland.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.graytonio = import ./systems/nixos/home.nix;
        }
      ];
    };

    darwinConfigurations.darwin = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs; };
      modules = [
        ./systems/darwin/configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.graytonw = import ./systems/darwin/home.nix;
        }
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "graytonw";
            mutableTaps = false;
            taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
            };
          };
        }
        ({config, ...}: {
            homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
        })
      ];
    };

    darwinConfigurations.work = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs; };
      modules = [
        ./systems/darwin/configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.graytonw = import ./systems/work/home.nix;
        }
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "graytonw";
	    mutableTaps = false;
            taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
	    	"deskflow/homebrew-tap" = deskflow;
		"graytonio/homebrew-brief" = brief;
            };
          };
        }

       ({config, ...}: {
           homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
       })
      ];
    };
  };
}
