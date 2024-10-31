{ config, pkgs, ... }: {
  home.packages = with pkgs; [ btop neofetch ];

  imports = [
    ./nvim 
    ./spotify.nix 
    ./yazi.nix
  ];
}
