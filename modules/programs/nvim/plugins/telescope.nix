
{
  programs.nixvim = {
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
