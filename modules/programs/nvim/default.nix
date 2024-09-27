{ inputs, pkgs, ... }: {
  imports = [ inputs.nixvim.homeManagerModules.nixvim ./plugins ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;

    #colorschemes.dracula.enable = true;
    colorschemes.catppuccin = {
	enable = true;
	settings = {
	  flavor = "mocha";
    	};
    };

    globals.mapleader = " ";

    keymaps = [{
      mode = "n";
      key = "<leader>pv";
      action = "<cmd>Ex<CR>";
    }];
  };
}
