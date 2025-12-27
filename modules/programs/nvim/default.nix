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
      {mode = "n"; key = "<leader>a"; action = "<cmd>lua require('harpoon'):list():add() <cr>"; }
      {mode = "n"; key = "<leader>e"; action = "<cmd>lua require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) <cr>"; }
      {mode = "n"; key = "<leader>1"; action = "<cmd>lua require('harpoon'):list():select(1) <cr>"; }
      {mode = "n"; key = "<leader>2"; action = "<cmd>lua require('harpoon'):list():select(2) <cr>"; }
      {mode = "n"; key = "<leader>3"; action = "<cmd>lua require('harpoon'):list():select(3) <cr>"; }
      {mode = "n"; key = "<leader>4"; action = "<cmd>lua require('harpoon'):list():select(4) <cr>"; }
    ];
  };
}
