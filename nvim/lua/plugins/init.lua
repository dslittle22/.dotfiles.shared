return { 
	{ "tpope/vim-commentary" },
	{ "tpope/vim-surround" },

  {
    'nvim-mini/mini.files',
    version = '*',
    opts = {
      options = {
        use_as_default_explorer = true,
      },
    },
  },


	{
		"EdenEast/nightfox.nvim",
		config = function() vim.cmd.colorscheme('nightfox') end
	},

	{
		"ibhagwan/fzf-lua",
		config = function()
			local fzf = require("fzf-lua")
			vim.keymap.set("n", "<leader>p", fzf.files, { desc = "Find files" })
			vim.keymap.set("n", "<leader>g", fzf.live_grep, { desc = "Live grep" })
			vim.keymap.set("n", "<leader>b", fzf.buffers, { desc = "Buffers" })
			vim.keymap.set("n", "<leader>r", function()
				fzf.oldfiles({ cwd_only = true })
			end, { desc = "Recent files" })
			vim.keymap.set("n", "<leader>fh", fzf.helptags, { desc = "Help tags" })
		end,
	},


	{
		'nvim-treesitter/nvim-treesitter',
		lazy = false,
		build = ':TSUpdate',
		config = function()
			vim.api.nvim_create_autocmd('FileType', {
				pattern = '*',
				callback = function() pcall(vim.treesitter.start) end,
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
			})
			local select = require("nvim-treesitter-textobjects.select")
			vim.keymap.set({ "x", "o" }, "af", function() select.select_textobject("@function.outer", "textobjects") end)
			vim.keymap.set({ "x", "o" }, "if", function() select.select_textobject("@function.inner", "textobjects") end)
		end,
  },

  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      { dir = "~/src/neotest-hs-jasmine" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-hs-jasmine"),
        },
      })
    end,
    keys = {
      { "<leader>tn", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file tests" },
      { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Test output" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test summary" },
    },
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "prettierd", "prettier", stop_after_first = true },
          javascriptreact = { "prettierd", "prettier", stop_after_first = true },
          typescript = { "prettierd", "prettier", stop_after_first = true },
          typescriptreact = { "prettierd", "prettier", stop_after_first = true },
          css = { "prettierd", "prettier", stop_after_first = true },
          scss = { "prettierd", "prettier", stop_after_first = true },
          json = { "prettierd", "prettier", stop_after_first = true },
        },
        format_on_save = {
          timeout_ms = 3000,
          lsp_format = "fallback",
        },
      })
    end,
  },

}

