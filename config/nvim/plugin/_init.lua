vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://tpope.io/vim/surround.git",
  "https://tpope.io/vim/rhubarb.git",
  "https://tpope.io/vim/fugitive.git",
  "https://github.com/nvim-mini/mini.files",
  "https://github.com/dchinmay2/alabaster.nvim",
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/saghen/blink.indent",
  "https://github.com/esmuellert/codediff.nvim",
})


vim.cmd.colorscheme('alabaster')

require("nvim-autopairs").setup()

if require('hubspot').is_hubspot() then
  require('hubspot.plugins')
end

require('blink.indent').setup({
  static = { enabled = false },
  scope = {
    enabled = true,
    highlights = { 'BlinkIndent' },
  },
})
