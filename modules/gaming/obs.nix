{pkgs, inputs, ... }:
{
  home.packages = [
    pkgs.obs-studio
    pkgs.chatterino2
    pkgs.obs-cmd
  ];
}
