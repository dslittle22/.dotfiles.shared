set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

source ~/.vimrc


" lua require('leap').create_default_mappings()

" Function to insert debug log for word under cursor
function! InsertDebugLog()
    " Get the word under cursor
    let l:word = expand('<cword>')

    " Move to the next blank line
    normal! }
    
    " Create the log statement
    let l:log_text = 'console.log({ ' . l:word . ' })'
    
    " Insert new line below current line with the log statement
    call append(line('.'), l:log_text)

    execute "normal! j"
    " Format the line using the built-in formatter
    normal ==
endfunction

nnoremap <Leader>z :call InsertDebugLog()<CR>

if exists('g:vscode')
    " VSCode extension
    " nnoremap <leader>t <Cmd>lua require('vscode').action('testing.runAtCursor')<CR>
    nnoremap <leader>t <cmd>lua require('vscode-neovim').action('testing.runAtCursor')<cr>
else
    " ordinary Neovim
endif
