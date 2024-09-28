{pkgs, ... }:
{
  home.packages = with pkgs; [
    steam
    mangohud
    protonup
    gamescope
  ];
}
