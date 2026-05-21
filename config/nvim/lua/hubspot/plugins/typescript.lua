vim.pack.add({
  'git@github.com:HubSpotShare/bend.nvim.git',
  'https://github.com/pmizio/typescript-tools.nvim',
  'https://github.com/neovim/nvim-lspconfig',
})

local bend = require('bend')
bend.setup({ v2 = true, auto_add_dirs = true })


require('typescript-tools').setup({
  single_file_support = false,
  root_dir = function(bufnr, on_dir)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if not bufname:match('^/') then
      return
    end
    on_dir(require('typescript-tools.utils').get_root_dir(bufnr))
  end,
  settings = {
    tsserver_path = bend.getTsServerPathForCurrentFile(),
    tsserver_plugins = {
      '@styled/typescript-styled-plugin',
    },
  },
})

-- ESLint LSP with auto-fix on save
local base_eslint_on_attach = vim.lsp.config.eslint.on_attach
vim.lsp.config('eslint', {
  root_dir = function(bufnr, on_dir)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    -- Skip JS files in acceptance-test directories where hs-eslint's
    -- babel setup is incompatible with the generic eslint LSP
    if bufname:match('/acceptance%-tests/') and bufname:match('%.js$') then
      return
    end
    on_dir(vim.fs.root(bufnr, { '.eslintrc', '.eslintrc.js', '.eslintrc.json' }))
  end,
  on_attach = function(client, bufnr)
    if base_eslint_on_attach then
      base_eslint_on_attach(client, bufnr)
    end

    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      command = 'LspEslintFixAll',
    })
  end,
})
vim.lsp.enable('eslint')


vim.lsp.config('bend', {
  cmd = { 'bend', 'lsp', '--session-path', vim.fn.getenv("BEND_SESSION_PATH") },
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'json'
  },
  root_markers = { '.git', 'build-info.json' },
})

vim.lsp.enable({ 'bend' })
