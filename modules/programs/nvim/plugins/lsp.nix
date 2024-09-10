{pkgs, ...}: {
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;

      #settings = {
      #  auto_install = true;
      #  highlight = {
      #    enable = true;
      #  };
      #};

      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
	rust
	go
	python
	json
	yaml
      ];
    };
  };
}
