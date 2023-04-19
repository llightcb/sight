set shell=/bin/sh

" plugins
call plug#begin('~/.local/share/nvim/plugged')
Plug 'dense-analysis/ale'
call plug#end()

" general
set nowritebackup
set noswapfile
set lazyredraw
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
augroup trailing
    au!
    au BufWritePre * :%s/\s\+$//e
augroup END

" cursor
augroup cursoroe
    au!
    au VimLeave * set gcr=a:hor20-blinkon1
augroup END

" jsonjq
command! -nargs=0
            \ Jq %!jq

" aleoff
let g:ale_enabled = 0

" alerst
let g:ale_lint_on_text_changed = 'always'
let g:ale_lint_delay = 200
"" let g:ale_open_list = 1
let g:ale_use_neovim_diagnostics_api = 1

" keymaps
nmap <silent> <C-j> <Plug>(ale_next_wrap)
nmap <silent> <C-l> <Plug>(ale_toggle)
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
