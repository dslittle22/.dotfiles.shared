vim.pack.add({
  'https://github.com/nvim-neotest/neotest',
  'https://github.com/nvim-neotest/nvim-nio',
  { src = 'git@github.com:HubSpotShare/neotest-hs-jasmine.git' },
  -- TODO: when neovim/neovim#37727 lands, use local path for development:
  -- { src = '~/src/neotest-hs-jasmine' },
})

require('neotest').setup({
  adapters = {
    require('neotest-hs-jasmine'),
  },
})

vim.keymap.set('n', '<leader>tn', function() require('neotest').run.run() end, { desc = 'Run nearest test' })
vim.keymap.set('n', '<leader>tf', function() require('neotest').run.run(vim.fn.expand('%')) end,
  { desc = 'Run file tests' })
vim.keymap.set('n', '<leader>to', function() require('neotest').output.open({ enter = true }) end,
  { desc = 'Test output' })
vim.keymap.set('n', '<leader>ts', function() require('neotest').summary.toggle() end, { desc = 'Test summary' })
