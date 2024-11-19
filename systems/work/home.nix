{config, pkgs, ...}: {
  imports = [
    ../../modules/shell
    ../../modules/programs/nvim.nix
    ../../modules/programming
  ];

  programs.fish = {
    shellAliases = {
      nixup = "darwin-rebuild switch --flake ~/repos/nixos-config/#work";
    };
  };

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
