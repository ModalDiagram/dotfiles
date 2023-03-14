"For C/C++ header files
function Insert_gates()
  let gatename = substitute(toupper(expand("%:t")), "\\.", "_", "g")
  execute "normal! i#ifndef " . gatename
  execute "normal! o#define " . gatename . " "
  execute "normal! Go#endif /* " . gatename . " */"
  normal! kk
endfunction

"Python configs
function Insert_py()
	execute "normal! i#!/usr/bin/env python"
	execute "normal! o"
	execute "normal! o"
	" Uncomment below if you need main
	"execute "normal! o"
	"execute "normal! o"
	"execute "normal! oif __name__ == \"__main__\":"
endfunction

function Insert_sh()
	execute "normal! i#!/bin/bash"
	normal! o
	normal! o
endfunction

function Insert_java()
  let iniz = expand("%:p")
  let src = matchend(expand(iniz), "src")
  " execute "normal! isrc " . src . ";"
  if src == -1
    return
  endif
  let path = expand(iniz)[src+1:-6]
  " execute "normal! ipath " . path . ";"
  let main_java = matchend(expand(path), "main/java")
  " execute "normal! imainjava " . main_java . ";"
  if main_java != 1
    let path = expand(path)[main_java+1:]
  endif
  " execute "normal! ipath " . path . ";"
  let last_slash = matchend(path, '.*\zs/')
  if last_slash != -1
    let package = substitute(path[0:last_slash-2],'/','.', 'g')
    execute "normal! ipackage " . package . ";"
    normal! o
    normal! o
  else
    let last_slash=0
  endif
  execute "normal! ipublic class " . path[last_slash:-1] . "{"
  normal! o
  normal! o
  execute "normal! i}"
endfunction

function Insert()
  if &filetype=='java'
    call Insert_java()
  elseif &filetype=='sh'
    call Insert_sh()
  endif
endfunction

function Open_at_dir()
  if isdirectory(expand("%:p"))
    cd %:p
    lua require("nvim-tree.api").tree.open()
  endif
endfunction

function Save_last_file()
  let path=[expand("%:p")]
  call writefile(path, "/tmp/nvim_last_file")
endfunction
