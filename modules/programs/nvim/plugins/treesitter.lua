{pkgs, ...}:{
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;
      auto_install = true;
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
	rust
	go
	python
	json
	yaml
      ];
      highlight = {
        enable = true;
	additional_vim_regex_highlighting = false;
      };
    };
  };
}
