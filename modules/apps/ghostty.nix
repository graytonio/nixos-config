{ pkgs, lib, ... }: {
  programs.ghostty = {
    enable = pkgs.stdenv.isLinux;
    enableFishIntegration = pkgs.stdenv.isLinux;
  };
}
