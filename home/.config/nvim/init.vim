let mapleader=","
let maplocalleader="\\"

let g:vimsyn_embed = 'lPr'  " support embedded lua, python and ruby

lua require('init')

" personalization
set nowrap
set shiftround
set expandtab
set tabstop=2
set shiftwidth=2

set autoread
set statusline="%f%m%r%h%w [%Y] [0x%02.2B]%< %F%=%4v,%4l %3p%% of %L"

set number
set splitbelow

" Disable providers we don't need
let g:loaded_ruby_provider = 0
let g:loaded_perl_provider = 0

" Clear highlighting after search
:nnoremap <leader>c :noh<CR>

" Use + and - to move codelines up and down
:nnoremap + ddp
:nnoremap - ddkP

" Make newlines without entering insert mode
:nnoremap <leader>o o<esc>
:nnoremap <leader>O O<esc>

" Window management
:nnoremap <leader><Bar> :wincmd v<CR>
:nnoremap <leader>_ :wincmd s<CR>
:nnoremap <leader>x :wincmd q<CR>
:nnoremap <leader>= :wincmd =<CR>
:nnoremap <leader>w :wincmd w<CR>
:nnoremap <leader>h :wincmd h<CR>
:nnoremap <leader>l :wincmd l<CR>
:nnoremap <leader>j :wincmd j<CR>
:nnoremap <leader>k :wincmd k<CR>

" Tab management
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

" Disable arrow keys to enforce hjkl
:nnoremap <left> <nop>
:nnoremap <right> <nop>
:nnoremap <up> <nop>
:nnoremap <down> <nop>

:inoremap <left> <nop>
:inoremap <right> <nop>
:inoremap <up> <nop>
:inoremap <down> <nop>
