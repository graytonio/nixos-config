{pkgs, ...}: {
  programs.nixvim = {
    plugins.lsp = {
      enable = true;
      
      keymaps = {
        lspBuf = {
	  gd = "definition";
	  gD = "references";
	  gt = "type_definition";
	  gi = "implementation";
	  K = "hover";
	  "<F2>" = "rename";
	};
      };

      servers = {
        gopls.enable = true;
	jsonls.enable = true;
	nixd.enable = true;
      };
    };
  };
}
