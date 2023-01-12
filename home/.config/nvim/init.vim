" nvim is always nocompatible

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
