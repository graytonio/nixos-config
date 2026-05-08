{ config, pkgs, ... }: {
  home.username = "graytonw";
  home.homeDirectory = "/Users/graytonw";

  imports = [
    ../../modules/base
    ../../modules/dev
    ../../modules/apps
  ];

  programs.fish.shellAliases = {
    nixup = "darwin-rebuild switch --flake ~/repos/nixos-config/#darwin";
  };

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
