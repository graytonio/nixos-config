{ pkgs, ... }: {
  home.username = "graytonio";
  home.homeDirectory = "/home/graytonio";

  imports = [
    ../../modules/shell
  ];

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}