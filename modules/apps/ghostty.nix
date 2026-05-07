{ pkgs, lib, ... }: {
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
  };
}
