{ pkgs, lib, ... }: {
  programs.ghostty = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    enableFishIntegration = true;
  };
}
