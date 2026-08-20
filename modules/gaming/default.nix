{ pkgs, ... }: {
  imports = [
    ./steam.nix
  ];

  home.packages = with pkgs; [
    wineWow64Packages.waylandFull
    winetricks
    prismlauncher
    samrewritten
  ];
}
