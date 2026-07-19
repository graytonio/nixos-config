{ pkgs, lib, ... }:
let
  envUser = builtins.getEnv "USER";
  envHome = builtins.getEnv "HOME";
in {
  home.username =
    if pkgs.stdenv.isDarwin then "graytonw"
    else if envUser != "" then envUser
    else throw "Could not read $USER — run home-manager with --impure";
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/graytonw"
    else if envHome != "" then envHome
    else throw "Could not read $HOME — run home-manager with --impure";

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
    else "home-manager switch --flake ~/nixos-config/#shell-linux --impure";

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
