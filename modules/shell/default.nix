{config, ...}: {
  imports = [
    ./fish.nix
    ./starship.nix
  ];

  home.sessionVariables = {
    EDITOR = "vim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
  };
}
