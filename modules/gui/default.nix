{ pkgs, ... }: {
  imports = [ ./alacritty.nix ./kitty.nix ];

  home.packages = with pkgs; [ vscode spotify ];
}
