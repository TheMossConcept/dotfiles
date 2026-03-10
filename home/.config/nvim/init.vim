let mapleader=","
let maplocalleader="\\"

let g:vimsyn_embed = 'lPr'  " support embedded lua, python and ruby

call plug#begin('~/.vim/plugged')
" The color scheme I currently use
Plug 'dikiaap/minimalist'

filetype plugin indent on

call plug#end()

colorscheme minimalist

lua require('init')

" personilzation here
set nowrap
set shiftround
set expandtab
set tabstop=2 
set shiftwidth=2

set autoread
set statusline="%f%m%r%h%w [%Y] [0x%02.2B]%< %F%=%4v,%4l %3p%% of %L"

set number
set splitbelow
let g:syntastic_typescript_checkers = ['tslint', 'tsc']
let g:syntastic_cs_checkers = ['code_checker']
let g:rustfmt_autosave = 1

" Disable providers we don't need
let g:loaded_ruby_provider = 0
let g:loaded_perl_provider = 0

" Clear highlighting after search
:nnoremap <leader>c :noh<CR>

" Use + and - to move codelines up and down - I don't use + and - default
" functionality anyway so skip leader to make them faster and easier to use
:nnoremap + ddp
:nnoremap - ddkP

" Make newlines without entering insert mode
:nnoremap <leader>o o<esc>
:nnoremap <leader>O O<esc> 

" Make working with windows easier  <Ctrl>ws
" :nnoremap <leader>| :wimcmd s<CR>
:nnoremap <leader><Bar> :wincmd v<CR>
:nnoremap <leader>_ :wincmd s<CR>
:nnoremap <leader>x :wincmd q<CR>
:nnoremap <leader>= :wincmd =<CR>
:nnoremap <leader>w :wincmd w<CR>
:nnoremap <leader>h :wincmd h<CR>
:nnoremap <leader>l :wincmd l<CR>
:nnoremap <leader>j :wincmd j<CR>
:nnoremap <leader>k :wincmd k<CR>

" Getting windows to be full screen using tabs and working with tabs in
" general
:nnoremap <leader>ts :tab split<CR>
:nnoremap <leader>tc :tabc<CR>
:nnoremap <leader>t gt 
:nnoremap <leader>T gT

" Easy copy to clipboard 
:nnoremap cy "+y
:nnoremap cyy "+yy
:nnoremap cY "+Y
:nnoremap cp "+p
:nnoremap cP "+P

" Easy save
:nnoremap <leader>s :w<CR>

" Upper case in insert mode and normal mode
:inoremap <leader>u <esc>lviwUEa<space>
:nnoremap <leader>u viwUE<esc>

" Allow for easy edition of this file
:nnoremap <leader>ei :split $MYVIMRC<cr>
:nnoremap <leader>si :source $MYVIMRC<cr>

" Put quotes around words and selection
:nnoremap <leader>" viw<esc>a"<esc>bi"<esc>lel
:nnoremap <leader>' viw<esc>a'<esc>bi'<esc>lel
:vnoremap <leader>' <esc>`<i'<esc>`>a'
:vnoremap <leader>" <esc>`<i"<esc>`>a"

" Easier switching back and forth between buffers
:nnoremap <leader>n :bn<CR>

" Easier access to normal mode
:inoremap jk <esc>
:inoremap <esc> <nop>

" Disable keys that I should not be using
:nnoremap <left> <nop>
:nnoremap <right> <nop>
:nnoremap <up> <nop>
:nnoremap <down> <nop>

:inoremap <left> <nop>
:inoremap <right> <nop>
:inoremap <up> <nop>
:inoremap <down> <nop>
:inoremap <bs> <nop>

" Autocommands to set filetypes
:autocmd BufNewFile,BufRead *.tsx set filetype=typescript.tsx
:autocmd BufNewFile,BufRead *.ts set filetype=typescript

" Autocommands for specific filetypes
:autocmd FileType tsx nnoremap <buffer> <localleader>c I//<space>
:autocmd FileType tsx nnoremap <buffer> <localleader>mc I/*<space>
:autocmd FileType tsx nnoremap <buffer> <localleader>xc I{/*<space>

" Abbreviations
:iabbrev co const
:iabbrev im import
