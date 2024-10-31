{pkgs, ...}: {
  services.nix-daemon.enable = true;

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.hostPlatform = "x86_64-darwin";

  environment.systemPackages = with pkgs; [ git vim wget curl ];

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  system.stateVersion = 5;
}