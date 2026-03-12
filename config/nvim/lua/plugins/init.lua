local plugins = {
  { "tpope/vim-surround" },
  { 'lewis6991/gitsigns.nvim', opts = {} },

  {
    "EdenEast/nightfox.nvim",
    config = function() vim.cmd.colorscheme('nightfox') end
  },

  {
    "NeogitOrg/neogit",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "esmuellert/codediff.nvim",
        opts = {
          highlights = {
            line_insert = "#2d4745",
          },
        },
      },

      "ibhagwan/fzf-lua", -- optional
    },
    cmd = "Neogit",
    keys = {
      { "<leader>g", "<cmd>Neogit<cr>", desc = "Show Neogit UI" }
    }
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
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
}

if require("hubspot").is_hubspot() then
  for _, plugin in ipairs(require("hubspot.plugins")) do
    table.insert(plugins, plugin)
  end
end

return plugins
