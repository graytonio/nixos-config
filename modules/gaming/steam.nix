{pkgs, ... }:
{
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  environment.systemPackage = with pkgs; [
    mangohud
  ];
}