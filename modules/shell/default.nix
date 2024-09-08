{config, ...}: {
  imports = [
    ./starship.nix
  ];

  home.sessionVariables = {
    EDITOR = "vim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
  };
}
