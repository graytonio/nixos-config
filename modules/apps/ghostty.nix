{ pkgs, lib, ... }: {
  programs.ghostty = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    enable = true;
    enableFishIntegration = true;
  };
}
