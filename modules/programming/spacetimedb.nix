{pkgs, ...}: {
  home.packages = with pkgs; [
    spacetimedb
  ];
}
