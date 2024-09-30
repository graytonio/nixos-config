{pkgs, ...}:
{
  services.mako = {
    enable = true;
    defaultTimeout = 2000;
    backgroundColor = "#1E1E2E";
    textColor = "#CDD6F4";
    borderColor = "#89B4FA";
  };

  home.packages = with pkgs; [
    libnotify
  ];
}
