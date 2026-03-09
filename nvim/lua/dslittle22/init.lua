vim.g.mapleader = " "
vim.o.shada = "'50,<50,s10"  -- remember only 50 files instead of default 100+
require("dslittle22.remap")
require("dslittle22.settings")
require("dslittle22.lazy")

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function()
		local opts = { buffer = 0 }
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
		vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
		vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
		vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, opts)
		vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
	end,
})
