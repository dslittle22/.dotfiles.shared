vim.keymap.set("n", "<leader>e", function()
  if not MiniFiles.close() then MiniFiles.open(vim.api.nvim_buf_get_name(0)) end
end, { desc = "Toggle file explorer (current file)" })

vim.keymap.set("n", "<leader>E", "<Cmd>lua MiniFiles.open()<CR>", { desc = "Open file explorer (cwd)" })
