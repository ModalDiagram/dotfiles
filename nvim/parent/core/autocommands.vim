augroup cdpwd
    autocmd!
    autocmd VimEnter * cd $PWD
augroup END

augroup ft_insert
  autocmd!
  autocmd BufNewFile *.{h,hpp} call Insert_gates()
  autocmd BufNewFile *.{py} call Insert_py()
  autocmd BufNewFile *.{sh} call Insert_sh()
  autocmd BufNewFile *.{java} call Insert_java()
augroup end

autocmd VimEnter * call Open_at_dir()
autocmd BufWinLeave * call Save_last_file()


" Define or override some highlight groups
augroup custom_highlight
  autocmd!
  autocmd VimEnter * call s:custom_highlight()
augroup END

function! s:custom_highlight() abort
  " For yank highlight
  highlight @method guifg=#c4a7e7
  highlight conditional guifg=#ebbcba
  highlight keyword guifg=#eb6f92
  highlight @attribute guifg=#ffe14d

endfunction

augroup change_hidden
  autocmd!
  autocmd BufNewFile,BufRead *.hidden set filetype=c
augroup END

