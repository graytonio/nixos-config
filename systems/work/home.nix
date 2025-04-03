{config, pkgs, ...}: {
  imports = [
    ../../modules/shell
    ../../modules/programs/nvim
    ../../modules/programming
    ../../modules/programming/apollo.nix
  ];

  programs.fish = {
    shellAliases = {
      nixup = "darwin-rebuild switch --flake ~/repos/nixos-config/#work";
    };
  };

  programs.tmux = {
    extraConfig = ''
      bind C-q run-shell "fish -c 'tmux-session /Users/graytonw/repos/monorepo'" 
      bind C-w run-shell "fish -c 'tmux-session /Users/graytonw/repos/apollo-argo'" 
      bind C-e run-shell "fish -c 'tmux-session /Users/graytonw/repos/scratch'" 
    '';
  };

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
