augroup ft_insert
  autocmd!
  autocmd BufNewFile *.{h,hpp} call Insert_gates()
  autocmd BufNewFile *.{py} call Insert_py()
  autocmd BufNewFile *.{sh} call Insert_sh()
  autocmd BufNewFile *.{java} call Insert_java()
augroup end

autocmd VimEnter * call Open_at_dir()
autocmd BufWinLeave * call Save_last_file()

autocmd FileType nix setlocal commentstring=#\ %s

" Define or override some highlight groups
augroup custom_highlight
  autocmd!
  autocmd VimEnter * call s:custom_highlight()
augroup END

function! s:custom_highlight() abort
  " For yank highlight
  highlight CmpItemAbbrMatchDefault guifg=#002b36
  highlight CmpItemAbbrMatchFuzzyDefault guifg=#002b36
  " highlight @method guifg=#c4a7e7
  " highlight conditional guifg=#ebbcba
  " highlight keyword guifg=#eb6f92
  " highlight @attribute guifg=#ffe14d

endfunction
