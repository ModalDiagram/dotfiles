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
  let path = expand(iniz)[matchend(expand(iniz), "src")+1:-6]
  let last_slash = matchend(path, '.*\zs/')
  let package = substitute(path[0:last_slash-2],'/','.', 'g')
  execute "normal! ipackage " . package . ";"
  normal! o
  normal! o
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
