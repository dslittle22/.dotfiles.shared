return {
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("ts_context_commentstring").setup({ enable_autocmd = false })
		end,
	},

	{
		"pmizio/typescript-tools.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"neovim/nvim-lspconfig",
			{
				url = "git@github.com:HubSpotEngineering/bend.nvim.git",
			},
		},
		ft = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
		config = function()
			local bend = require("bend")
			bend.setup({ v2 = true })

			require("typescript-tools").setup({
				settings = {
					tsserver_path = bend.getTsServerPathForCurrentFile(),
				},
			})
		end,
	},
}
