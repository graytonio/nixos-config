{pkgs, ... }:
{
  home.packages = with pkgs; [
    obs-studio
    chatterino2
  ];
}
