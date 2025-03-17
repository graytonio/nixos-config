{pkgs, ...}: {
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [ git vim wget curl ];

  users.users.graytonw = {
    name = "graytonw";
    home = "/Users/graytonw";
  };

  fonts.packages = with pkgs;
    [ (nerdfonts.override { fonts = [ "FiraCode" ]; }) ];

  services.aerospace.enable = false;
  services.aerospace.settings = {
	accordion-padding = 300;
	default-root-container-layout = "tiles";
	default-root-container-orientation = "auto";
	key-mapping = {
	  preset = "qwerty";
	};
  };

  programs.fish.enable = true;
  system.stateVersion = 5;
  services.nix-daemon.enable = true;
}
