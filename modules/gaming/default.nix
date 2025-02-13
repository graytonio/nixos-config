{ pkgs, ... }: {
  imports = [
    ./steam.nix
    ./obs.nix
  ];

  home.packages = with pkgs; [
    wineWowPackages.waylandFull
    winetricks
  ];
}
