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

    keymaps = [
      {mode = "n"; key = "<leader>pv"; action = "<cmd>Ex<CR>";}
      {mode = "n"; key = "<leader>a"; action = "function() require'harpoon':list():add() end"; }
      {mode = "n"; key = "<leader>e"; action = "function() require'harpoon'.ui:toggle_quick_menu(require'harpoon':list()) end"; }
      {mode = "n"; key = "<leader>1"; action = "function() require'harpoon':list():select(1) end"; }
      {mode = "n"; key = "<leader>2"; action = "function() require'harpoon':list():select(2) end"; }
      {mode = "n"; key = "<leader>3"; action = "function() require'harpoon':list():select(3) end"; }
      {mode = "n"; key = "<leader>4"; action = "function() require'harpoon':list():select(4) end"; }
    ];
  };
}
