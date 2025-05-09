" let g:python3_host_prog = "/home/sandro0198/anaconda3/envs/nvim/bin/python3"
let g:python3_host_prog = "python3"

set termguicolors
set background=light
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
set colorcolumn=80 " linea per la lunghezza
highlight ColorColumn guibg=#eee8d5

set updatetime=1000
" Impostazioni sui tab
set tabstop=2       " number of visual spaces per TAB
set softtabstop=2   " number of spaces in tab when editing
set shiftwidth=2    " number of spaces to use for autoindent
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

set cursorline
let R_min_editor_width = 20
let R_pdfviewer="okular"
