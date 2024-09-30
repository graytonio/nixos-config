{inputs, pkgs, ...}:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system};
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  home.packages = [
    pkgs.playerctl
  ];

  programs.ncspot = {
    enable = true;
  };

  programs.spicetify = {
	enable = true;
	
	spicetifyPackage = unstable.spicetify-cli;

	theme = spicePkgs.themes.catppuccin;
	colorScheme = "mocha";

	enabledCustomApps = builtins.attrValues {
	  inherit(spicePkgs.apps)
	  ncsVisualizer
	  nameThatTune
	  lyricsPlus;
	};

	enabledExtensions = builtins.attrValues {
	  inherit(spicePkgs.extensions)
	  hidePodcasts
	  songStats
	  beautifulLyrics
	  adblock;
	};
  };
}
