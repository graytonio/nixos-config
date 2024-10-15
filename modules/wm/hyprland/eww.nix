{pkgs, ...}:
{
  home.packages = [ 
    pkgs.eww
  
    pkgs.python311Packages.dbus-python
    pkgs.python311Packages.pygobject3
  ];

  home.file.".config/eww/".source = ./eww;
}

