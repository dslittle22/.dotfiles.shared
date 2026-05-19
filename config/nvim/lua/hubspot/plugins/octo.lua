vim.pack.add({ "https://github.com/pwntester/octo.nvim" })

require("octo").setup({
  picker = "fzf-lua",
  use_local_fs = true,
})
