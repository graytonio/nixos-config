{ inputs, ... }: {
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;

    globals.mapleader = " ";

    keymaps = [{
      mode = "n";
      key = "<leader>pv";
      action = "<cmd>Ex<CR>";
    }];

    plugins.telescope = {
      enable = true;
      keymaps = {
        "<leader>pf" = "find_files";
        "<leader>pg" = "git_files";
        "<leader>ps" = "live_grep";
      };
    };
  };
}
