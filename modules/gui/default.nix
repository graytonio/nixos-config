{ pkgs, ... }: {
  imports = [ ./alacritty.nix ./kitty.nix ];

  home.packages = with pkgs; [ vscode ]
    ++ (pkgs.lib.optionals pkgs.stdenv.isLinux [ pwvucontrol ]);
}
