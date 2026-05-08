{ pkgs, lib, ... }: {
  home.username = if pkgs.stdenv.isDarwin then "graytonw" else "graytonio";
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/graytonw" else "/home/graytonio";

  nixpkgs.config.allowUnfree = true;

  imports = [
    ../../modules/base
    ../../modules/dev
    ../../modules/apps
  ];

  # Mac convention is ~/repos/nixos-config; Linux convention is ~/nixos-config
  programs.fish.shellAliases.nixup =
    if pkgs.stdenv.isDarwin
    then "home-manager switch --flake ~/repos/nixos-config/#shell-darwin"
    else "home-manager switch --flake ~/nixos-config/#shell-linux";

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
