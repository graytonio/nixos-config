{ pkgs, lib, ... }: {
  programs.firefox.enable = true;
  programs.firefox.configPath = ".mozilla/firefox";
}
