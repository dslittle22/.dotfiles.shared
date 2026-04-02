return {
  require("hubspot.plugins.typescript-tools"),
  require("hubspot.plugins.eslint"),
  require("hubspot.plugins.neotest"),

  {
    "saghen/blink.cmp",
    dependencies = {
      "giuxtaposition/blink-cmp-copilot",
    },
    opts = {
      sources = {
        default = { "hs_translations", "copilot" },
        providers = {
          hs_translations = {
            name = "Translations",
            module = "blink-hs-translations",
            score_offset = -3,
            async = true,
          },
          copilot = {
            name = "copilot",
            module = "blink-cmp-copilot",
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  },

  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    keys = {
      { "<C-.>", function() require("opencode").toggle() end, desc = "Toggle opencode" },
      { "<C-a>", function() require("opencode").ask() end, mode = { "n", "v" }, desc = "Ask opencode" },
      { "<C-x>", function() require("opencode").select() end, mode = { "n", "v" }, desc = "Execute opencode action" },
      { "go", function() return require("opencode").operator("@this ") end, mode = { "n", "v" }, expr = true, desc = "Add range to opencode" },
      { "goo", function() return require("opencode").operator("@this ") .. "_" end, expr = true, desc = "Add line to opencode" },
      { "<S-C-u>", function() require("opencode").command("session.half.page.up") end, desc = "Scroll opencode up" },
      { "<S-C-d>", function() require("opencode").command("session.half.page.down") end, desc = "Scroll opencode down" },
    },
    config = function()
      -- Use dvx wrapper instead of raw opencode binary to get HubSpot LiteLLM auth
      local cmd = "dvx opencode --port"
      local term_opts = {
        split = "right",
        width = math.floor(vim.o.columns * 0.35),
      }
      -- Override server start/stop/toggle to use dvx wrapper
      -- (default uses bare "opencode --port" which bypasses shell aliases)
      vim.g.opencode_opts = {
        server = {
          start = function()
            require("opencode.terminal").open(cmd, term_opts)
          end,
          stop = function()
            require("opencode.terminal").close(cmd, term_opts)
          end,
          toggle = function()
            require("opencode.terminal").toggle(cmd, term_opts)
          end,
        },
      }
      vim.o.autoread = true
    end,
  },

  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    dependencies = {
      {
        "copilotlsp-nvim/copilot-lsp",
        init = function()
          vim.g.copilot_nes_debounce = 500
        end,
      },
    },
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      nes = {
        enabled = true,
        keymap = {
          accept_and_goto = "<tab>",
          dismiss = "<esc>",
        },
      },
    },
  }
}
