return { 
	{ "tpope/vim-commentary" },
	{ "tpope/vim-surround" },
  { "tpope/vim-fugitive" },

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
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
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
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = { 'rafamadriz/friendly-snippets' },

    version = '1.*',
    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = { preset = 'super-tab' },
      appearance = {
        nerd_font_variant = 'mono'
      },
      completion = { documentation = { auto_show = false } },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" }
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

