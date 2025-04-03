{pkgs, inputs, ... }:
{

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
	wlrobs
	obs-pipewire-audio-capture
	obs-backgroundremoval
	obs-webkitgtk
    ];
  };

  home.packages = [
    pkgs.chatterino2
    pkgs.obs-cmd
  ];
}
