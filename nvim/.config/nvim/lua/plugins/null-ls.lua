return {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
	require("null-ls").setup({
	    sources = {
	      require("null-ls").builtins.code_actions.shellcheck,
	      require("null-ls").builtins.diagnostics.shellcheck,
	    },
	})
    end,
}

