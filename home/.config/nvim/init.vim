" nvim is always nocompatible

" speedup
set shell=/bin/sh

" general
set nowritebackup
set noswapfile
set nobackup

" indent
set tabstop=8
set expandtab
set shiftwidth=4
set softtabstop=0

" colors
syntax enable
set background=light
hi String ctermfg=NONE
hi Comment ctermfg=grey
hi Operator ctermfg=blue
hi Statement ctermfg=NONE
hi Conditional ctermfg=lightred

" remove
augroup TrailwSpacew
    autocmd!
    au BufWritePre * :%s/\s\+$//e
augroup END

" cursor
augroup CursorOnExit
    autocmd!
    au VimLeave * set gcr=a:hor20-blinkon1
augroup END

" plugin
call plug#begin('~/.local/share/nvim/plugged')
Plug 'dense-analysis/ale'
call plug#end()

" aleoffd
let g:ale_enabled = 0

" alemisk
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_delay = 200
"" let g:ale_open_list = 1
let g:ale_use_neovim_diagnostics_api = 1

" alenavi
nmap <silent> <C-j> <Plug>(ale_next_wrap)
nmap <silent> <C-l> <Plug>(ale_toggle)
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
