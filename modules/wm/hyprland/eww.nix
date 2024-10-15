{pkgs, ...}:
{
  home.packages = [ pkgs.eww ];

  home.file.".config/eww/".source = ./eww;
}

