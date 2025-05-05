{ pkgs, ... }: {
  imports = [
    ./steam.nix
  ];

  home.packages = with pkgs; [
    wineWowPackages.waylandFull
    winetricks
    prismlauncher
    samrewritten
  ];
}
