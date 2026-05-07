{ config, ... }: {
  programs.starship = {
    enable = true;
    settings = {
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };

      directory = {
        truncate_to_repo = true;
        format = "[$path]($style)[$lock_symbol]($lock_style) ";
        style = "bold italic";
      };

      aws = { disabled = true; };

      azure = { disabled = true; };

      gcloud = { disabled = true; };

      kubernetes = { disabled = false; };

      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = "🌱 ";
      };

      git_status = { disabled = true; };

      username = {
        style_user = "bold dimmed blue";
        style_root = "black bold";
        format = "[$user]($style) ";
        disabled = false;
        show_always = true;
      };
    };
  };
}
