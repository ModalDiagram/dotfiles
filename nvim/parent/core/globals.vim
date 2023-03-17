let g:python3_host_prog = "/home/sandro0198/anaconda3/envs/nvim/bin/python3"

set title
set number relativenumber
set ignorecase
set smartcase
let mapleader = ","
nnoremap è \"+p
set splitbelow splitright
set noswapfile
set wildignorecase " ignore cases in cmd completions

set autochdir " per traferirsi automaticamente sulla directory del file
set colorcolumn=120 " linea per la lunghezza
set updatetime=1000
" Impostazioni sui tab
set tabstop=1       " number of visual spaces per TAB
set softtabstop=1   " number of spaces in tab when editing
set shiftwidth=1    " number of spaces to use for autoindent
set expandtab       " expand tab to spaces so that tabs are spaces

" Break line at predefined characters
set linebreak
" Character to show before the lines that have been soft-wrapped
set showbreak=↪

" Minimum lines to keep above and below cursor when scrolling
set scrolloff=3

" Persistent undo even after you close a file and re-open it
set undofile

set noruler
