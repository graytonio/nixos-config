{pkgs, ...}: {
  home.packages = with pkgs; [
    rover
  ];
}
