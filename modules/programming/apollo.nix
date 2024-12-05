{pkgs, ...}: {
  home.packages = with pkgs; [
    rover
    zulu17
  ];
}
