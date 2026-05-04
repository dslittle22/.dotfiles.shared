vim.keymap.set('n', ';', ':')
vim.keymap.set('n', ':', ';')

-- opt-backspace = delete word
vim.keymap.set('i', '<M-BS>', '<C-w>')

-- Allow window navigation from terminal mode without needing to escape first
vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>", { desc = "Window nav from terminal mode" })
vim.keymap.set('n', '<C-b>', '<C-6>')

-- when in visual mode, J and K to move line up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- paste without deleting current buffer, by yanking selection to null register
vim.keymap.set("x", "<leader>v", "\"_dp")

-- leader + y (or Y) to yank to system clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")


vim.keymap.set("n", "<leader>cp", function()
  local path = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
  vim.fn.setreg("+", path)
  vim.notify(path)
end, { desc = "Copy relative file path" })

vim.keymap.set("n", "<leader>cl", function()
  local path = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
  local line = path .. "#" .. vim.fn.line(".")
  vim.fn.setreg("+", line)
  vim.notify(line)
end, { desc = "Copy relative file path with line number" })

vim.keymap.set("v", "<leader>cl", function()
  local path = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
  local l1 = vim.fn.getpos('v')[2]
  local l2 = vim.fn.getpos('.')[2]
  local start_line = math.min(l1, l2)
  local end_line = math.max(l1, l2)
  local result = path .. "#" .. start_line .. "-" .. end_line
  vim.fn.setreg("+", result)
  vim.notify(result)
end, { desc = "Copy relative file path with line range" })


vim.keymap.set('n', '<leader>gc', '<cmd>GBrowse<cr>', { desc = 'Open on current branch' })
vim.keymap.set('v', '<leader>gc', ":'<,'>GBrowse<cr>", { desc = 'Open on current branch' })
vim.keymap.set('n', '<leader>gC', '<cmd>.GBrowse!<cr>', { desc = 'Copy current branch URL' })
vim.keymap.set('v', '<leader>gC', ":'<,'>GBrowse!<cr>", { desc = 'Copy current branch URL' })

vim.keymap.set('n', '<leader>gd', '<cmd>GBrowse master:%<cr>', { desc = 'Open on default branch' })
vim.keymap.set('v', '<leader>gd', ":'<,'>GBrowse master:%<cr>", { desc = 'Open on default branch' })
vim.keymap.set('n', '<leader>gD', '<cmd>.GBrowse! master:%<cr>', { desc = 'Copy default branch URL' })
vim.keymap.set('v', '<leader>gD', ":'<,'>GBrowse! master:%<cr>", { desc = 'Copy default branch URL' })

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-f>", "<C-f>zz")
vim.keymap.set("n", "<C-b>", "<C-b>zz")

vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

vim.keymap.set("t", "<C-Esc>", "<C-\\><C-n>")

vim.keymap.set('n', '<leader>gm', ':Git commit -m ""<left>', { desc = 'Git commit with message' })

vim.api.nvim_create_user_command('Svc', function()
  local dir = vim.fn.stdpath('config') .. '/lua/dslittle22'
  for _, file in ipairs({ 'remaps', 'settings' }) do
    vim.cmd('source ' .. dir .. '/' .. file .. '.lua')
  end
  vim.notify('Reloaded config')
end, {})

vim.keymap.set('n', '<leader>R', function()
  local session = vim.fn.stdpath('state') .. '/restart_session.vim'
  vim.cmd('mksession! ' .. vim.fn.fnameescape(session))
  vim.cmd('restart source ' .. vim.fn.fnameescape(session))
end, { desc = 'Restart Neovim' })


vim.keymap.set('n', '<leader>cd', function()
  local base = vim.fn.trim(vim.fn.system('git merge-base master HEAD'))
  vim.cmd('CodeDiff ' .. base .. ' HEAD')
end)

vim.api.nvim_create_user_command('CodeDiffPR', function(opts)
  local target = opts.args ~= '' and opts.args or 'HEAD'
  local base = vim.fn.trim(vim.fn.system('git merge-base master ' ..
    target))
  vim.cmd('CodeDiff ' .. base .. ' ' .. target)
end, { nargs = '?' })
