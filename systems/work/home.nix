{config, pkgs, ...}: {

  imports = [
    ../../modules/shell
    ../../modules/programs
    ../../modules/gui
    ../../modules/programming
  ];

  programs.fish = {
    shellAliases = {
      nixup = "sudo nixos-rebuild switch --flake ~/nixos-config/#work";
    };
  };

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}