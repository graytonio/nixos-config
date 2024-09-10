{config, pkgs, ...}: {
  home.packages = with pkgs; [
    btop
    neofetch
  ];

  imports = [
    ./tmux.nix
    ./nvim.nix
  ];
}
