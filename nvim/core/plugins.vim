" Plugin specification and lua stuff
lua require('plugins')

"""""""""""""""""""" Impostazioni di Vista"""""""""""""""""""
let g:vista#renderer#icons = {
      \ 'member': '',
      \ }

" Do not echo message on command line
let g:vista_echo_cursor = 0
" Stay in current window when vista window is opened
let g:vista_stay_on_open = 0

nnoremap <silent> <Space>t :<C-U>Vista!!<CR>

""""""""""""""""""""""""vim-mundo settings"""""""""""""""""""""""
let g:mundo_verbose_graph = 0
let g:mundo_width = 80

nnoremap <silent> <Space>u :MundoToggle<CR>

"""""""""""""""""""""""""UltiSnips settings"""""""""""""""""""
" Trigger configuration. Do not use <tab> if you use YouCompleteMe
let g:UltiSnipsExpandTrigger='<c-j>'

" Do not look for SnipMate snippets
let g:UltiSnipsEnableSnipMate = 0

" Shortcut to jump forward and backward in tabstop positions
let g:UltiSnipsJumpForwardTrigger='<c-j>'
let g:UltiSnipsJumpBackwardTrigger='<c-k>'

" Configuration for custom snippets directory
let g:UltiSnipsSnippetDirectories=['UltiSnips', 'my_snippets']


"""""""""""""""""""""""""""""LeaderF settings"""""""""""""""""""""
" Do not use cache file
let g:Lf_UseCache = 0
" Refresh each time we call leaderf
let g:Lf_UseMemoryCache = 0

" Ignore certain files and directories when searching files
let g:Lf_WildIgnore = {
  \ 'dir': ['.git', '__pycache__', '.DS_Store'],
  \ 'file': ['*.exe', '*.dll', '*.so', '*.o', '*.pyc', '*.jpg', '*.png',
  \ '*.gif', '*.svg', '*.ico', '*.db', '*.tgz', '*.tar.gz', '*.gz',
  \ '*.zip', '*.bin', '*.pptx', '*.xlsx', '*.docx', '*.pdf', '*.tmp',
  \ '*.wmv', '*.mkv', '*.mp4', '*.rmvb', '*.ttf', '*.ttc', '*.otf',
  \ '*.mp3', '*.aac']
  \}

" Only fuzzy-search files names
let g:Lf_DefaultMode = 'FullPath'

" Popup window settings
let w = float2nr(&columns * 0.8)
if w > 140
  let g:Lf_PopupWidth = 140
else
  let g:Lf_PopupWidth = w
endif

let g:Lf_PopupPosition = [0, float2nr((&columns - g:Lf_PopupWidth)/2)]

" Do not use version control tool to list files under a directory since
" submodules are not searched by default.
let g:Lf_UseVersionControlTool = 0

" Use rg as the default search tool
let g:Lf_DefaultExternalTool = "rg"

" show dot files
let g:Lf_ShowHidden = 1

" Disable default mapping
let g:Lf_ShortcutF = ''
let g:Lf_ShortcutB = ''

" set up working directory for git repository
let g:Lf_WorkingDirectoryMode = 'a'

" Search files in popup window
nnoremap <silent> <leader>ff :<C-U>Leaderf file --popup<CR>

" Grep project files in popup window
nnoremap <silent> <leader>fg :<C-U>Leaderf rg --no-messages --popup<CR>

" Search vim help files
nnoremap <silent> <leader>fh :<C-U>Leaderf help --popup<CR>

" Search tags in current buffer
nnoremap <silent> <leader>ft :<C-U>Leaderf bufTag --popup<CR>

" Switch buffers
nnoremap <silent> <leader>fb :<C-U>Leaderf buffer --popup<CR>

" Search recent files
nnoremap <silent> <leader>fr :<C-U>Leaderf mru --popup --absolute-path<CR>

" :lua << EOF
" vim.keymap.set('n', "<leader>ai", "")
" vim.keymap.set('n', "<leader>av", "<Cmd>lua require('jdtls').extract_variable()<CR>")
" vim.keymap.set('v', "<leader>av", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>")
" vim.keymap.set('v', "<leader>am", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>")
" vim.keymap.set('n', "<leader>aR", "<Cmd>lua require('jdtls').code_action(false, 'refactor')<CR>")

" local jdtls_ui = require'jdtls.ui'
" function jdtls_ui.pick_one_async(items, _, _, cb)
"   require'lsputil.codeAction'.code_action_handler(nil, nil, items, nil, nil, nil, cb)
" end
"   vim.cmd[[command! -buffer JdtCompile lua require('jdtls').compile()]]
"   vim.cmd[[command! -buffer JdtUpdateConfig lua require('jdtls').update_project_config()]]
"   vim.cmd[[command! -buffer JdtJol lua require('jdtls').jol()]]
"   vim.cmd[[command! -buffer JdtBytecode lua require('jdtls').javap()]]
"   vim.cmd[[command! -buffer JdtJshell lua require('jdtls').jshell()]]
" EOF


