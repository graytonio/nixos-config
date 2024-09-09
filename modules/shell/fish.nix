{config, pkgs, ...}:{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
    shellAliases = {
      tarnow = "tar -acf";
      untar = "tar -zxvf";

      cat = "bat";
      grep = "rg";
      la = "eza -a --color=always --group-directories-first --icons";
      ll = "eza -l --color=always --group-directories-first --icons";
      ls = "eza -la --color=always --group-directories-first --icons"; 
    };
  };
}

