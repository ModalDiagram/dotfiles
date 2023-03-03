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

