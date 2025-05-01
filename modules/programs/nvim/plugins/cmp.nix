{
  programs.nixvim = {
    plugins.cmp = {
      autoEnableSources = true;
      enable = true;
      settings.mapping = {
        "<Tab>" = ''
	  cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif vim.fn["vsnip#available"](1) == 1 then
              feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
              cmp.complete()
            else
              fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
            end
          end, { "i", "s" })'';
	"<S-Tab>" = ''
	  cmp.mapping(function()
	    if cmp.visible() then
              cmp.select_prev_item()
      	    elseif vim.fn["vsnip#jumpable"](-1) == 1 then
              feedkey("<Plug>(vsnip-jump-prev)", "")
      	    end
	  end, { "i", "s" })'';
	"<CR>" = ''
	 cmp.mapping({
           i = function(fallback)
           if cmp.visible() and cmp.get_active_entry() then
             cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
           else
             fallback()
           end
          end,
          s = cmp.mapping.confirm({ select = true }),
          c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
         })'';
      };
      settings.sources = [
        { name = "nvim_lsp"; }
        { name = "path"; }
        { name = "buffer"; }
      ];
    };
  };
}
