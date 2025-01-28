{ pkgs, ... }: {
  imports = [
    ./steam.nix
    ./obs.nix
  ];
}
