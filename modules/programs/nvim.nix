{config, pkgs, ...}:{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      {
        plugin = vimplugin-lua5.1-telescope.nvim-scm
        config = ''
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
          vim.keymap.set('n', '<leader>pg', builtin.git_files, {})
          vim.keymap.set('n', '<leader>ps', function()
	    builtin.grep_string({ search = vim.fn.input("Grep > ") });
          end)
        '';
      }
    ];
  };
}
