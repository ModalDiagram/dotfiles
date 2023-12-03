local keymap = vim.keymap
local api = vim.api
local uv = vim.loop

-- insert semicolon in the end
keymap.set({"n"}, "<space>;", "<Esc>miA;<Esc>`ii<Esc>")
keymap.set({"i"}, "<alt>;", "<Esc>miA;<Esc>`ii")

-- Save key strokes (now we do not need to press shift to enter command mode).
keymap.set({ "n", "x" }, ".", ":")

-- Turn the word under cursor to upper case
keymap.set("i", "<c-u>", "<Esc>viwUea")

-- Turn the current word into title case
keymap.set("i", "<c-t>", "<Esc>b~lea")

-- Paste non-linewise text above or below current line, see https://stackoverflow.com/a/1346777/6064933
keymap.set("n", "<leader>p", "m`o<ESC>p``", { desc = "paste below current line" })
keymap.set("n", "<leader>P", "m`O<ESC>p``", { desc = "paste above current line" })

------------------------- BUFFERS MAPPINGS ----------------------------------------
-- Shortcut for faster save and quit
keymap.set("n", "<leader>w", "<cmd>update<cr>", { silent = true, desc = "save buffer" })

-- Saves the file if modified and quit
keymap.set("n", "<leader>q", "<cmd>x<cr>", { silent = true, desc = "quit current window" })

-- Quit all opened buffers
keymap.set("n", "<leader>Q", "<cmd>qa!<cr>", { silent = true, desc = "quit nvim" })

-- move between buffers
keymap.set("n", "<a-h>", "<cmd>bprevious<cr>", { silent = true, desc = "previous buffer" })
keymap.set("n", "<a-l>", "<cmd>bnext<cr>", { silent = true, desc = "next buffer" })
keymap.set("i", "<a-h>", "<cmd>bprevious<cr>", { silent = true, desc = "previous buffer" })
keymap.set("i", "<a-l>", "<cmd>bnext<cr>", { silent = true, desc = "next buffer" })

-- Copy entire buffer.
keymap.set("n", "<leader>by", "<cmd>%yank<cr>", { desc = "yank entire buffer" })
keymap.set("n", "<leader>bD", "<cmd>bd!<cr>", { desc = "delete current buffer" })
keymap.set("n", "<leader>bd", "<cmd>w<cr><cmd>bd<cr>", { desc = "delete current buffer" })

-- Navigate with telescope (<c-d> to remove buffer)
keymap.set("n", "<c-b>t", "<cmd>Telescope buffers<cr>", { desc = "Telescope buffers" })




-- Insert a blank line below or above current line (do not move the cursor),
-- see https://stackoverflow.com/a/16136133/6064933
keymap.set("n", "<space>o", "printf('m`%so<ESC>``', v:count1)", {
  expr = true,
  desc = "insert line below",
})

keymap.set("n", "<space>O", "printf('m`%sO<ESC>``', v:count1)", {
  expr = true,
  desc = "insert line above",
})

-- Move the cursor based on physical lines, not the actual lines.
keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
keymap.set("n", "^", "g^")
keymap.set("n", "0", "g0")

-- Go to start or end of line easier
keymap.set({ "n", "x" }, "H", "^")
keymap.set({ "n", "x" }, "L", "g_")

-- Continuous visual shifting (does not exit Visual mode), `gv` means
-- to reselect previous visual area, see https://superuser.com/q/310417/736190
keymap.set("x", "<", "<gv")
keymap.set("x", ">", ">gv")

-- Reselect the text that has just been pasted, see also https://stackoverflow.com/a/4317090/6064933.
keymap.set("n", "<leader>v", "printf('`[%s`]', getregtype()[0])", {
  expr = true,
  desc = "reselect last pasted area",
})

-- Always use very magic mode for searching
keymap.set("n", "/", [[/\v]])

-- Change current working directory locally and print cwd after that,
-- see https://vim.fandom.com/wiki/Set_working_directory_to_the_current_file
keymap.set("n", "<leader>cd", "<cmd>lcd %:p:h<cr><cmd>pwd<cr>", { desc = "change cwd" })

-- Use Esc to quit builtin terminal
keymap.set("t", "<Esc>", [[<c-\><c-n>]])

-- Change text without putting it into the vim register,
-- see https://stackoverflow.com/q/54255/6064933
keymap.set("n", "c", '"_c')
keymap.set("n", "C", '"_C')
keymap.set("n", "cc", '"_cc')
keymap.set("x", "c", '"_c')

-- Remove trailing whitespace characters
keymap.set("n", "<leader><space>", "<cmd>StripTrailingWhitespace<cr>", { desc = "remove trailing space" })


-- Move current line up and down
-- keymap.set("n", "<A-k>", '<cmd>call utils#SwitchLine(line("."), "up")<cr>', { desc = "move line up" })
-- keymap.set("n", "<A-j>", '<cmd>call utils#SwitchLine(line("."), "down")<cr>', { desc = "move line down" })

-- Move current visual-line selection up and down
-- keymap.set("x", "<A-k>", '<cmd>call utils#MoveSelection("up")<cr>', { desc = "move selection up" })

-- keymap.set("x", "<A-j>", '<cmd>call utils#MoveSelection("down")<cr>', { desc = "move selection down" })

-- Windows mappings
keymap.set("n", "<c-w>e", "<cmd>WinResizerStartResize<CR>")
keymap.set("n", "<left>", "<c-w>h")
keymap.set("n", "<Right>", "<C-W>l")
keymap.set("n", "<Up>", "<C-W>k")
keymap.set("n", "<Down>", "<C-W>j")
keymap.set("n", "<c-h>", "<c-w>h")
keymap.set("n", "<c-l>", "<C-W>l")
keymap.set("n", "<c-k>", "<C-W>k")
keymap.set("n", "<c-j>", "<C-W>j")
keymap.set("i", "<c-h>", "<Esc><c-w>h")
keymap.set("i", "<c-l>", "<Esc><C-W>l")
keymap.set("i", "<c-k>", "<Esc><C-W>k")
keymap.set("i", "<c-j>", "<Esc><C-W>j")

-- Break inserted text into smaller undo units when we insert some punctuation chars.
local undo_ch = { ",", ".", "!", "?", ";", ":" }
for _, ch in ipairs(undo_ch) do
  keymap.set("i", ch, ch .. "<c-g>u")
end

-- Keep cursor position after yanking
keymap.set("n", "y", "myy")

api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  group = api.nvim_create_augroup("restore_after_yank", { clear = true }),
  callback = function()
    vim.cmd([[
      silent! normal! `y
      silent! delmarks y
    ]])
  end,
})

-- Go to the beginning and end of current line in insert mode quickly
keymap.set("i", "<c-a>", "<HOME>")
keymap.set("i", "<c-s>", "<END>")
-- Go to the beginning and end of current line in normal mode quickly
keymap.set("n", "<c-a>", "<HOME>")
keymap.set("n", "<c-s>", "<END>")

-- Go to beginning of command in command-line mode
keymap.set("c", "<C-A>", "<HOME>")

-- Delete the character to the right of the cursor
keymap.set("i", "<C-D>", "<DEL>")

-- Esc più comodo
keymap.set("i", "kj", "<ESC>")

-- Copio dall'unnamed register
keymap.set("n", "è", "\"+p")
keymap.set({"n", "v"}, "<C-y>", "\"+y")
keymap.set({"n", "v"}, "<C-p>", "\"+p")

-- Impostazioni di yanky
vim.keymap.set("n", "[", "<Plug>(YankyCycleForward)")
vim.keymap.set("n", "]", "<Plug>(YankyCycleBackward)")
vim.keymap.set({"n","x"}, "p", "<Plug>(YankyPutAfter)")
vim.keymap.set({"n","x"}, "P", "<Plug>(YankyPutBefore)")
vim.keymap.set({"n","x"}, "gp", "<Plug>(YankyGPutAfter)")
vim.keymap.set({"n","x"}, "gP", "<Plug>(YankyGPutBefore)")



-- Mappings di telescope
vim.keymap.set("n", "<leader>tp", "<cmd>Telescope projects<cr>", {
  desc = "Search for project"
})
vim.keymap.set("n", "<leader>td", '<cmd>lua require("telescope.builtin").find_files( { cwd = "/home/sandro0198/.config/nvim/" })<cr>', {
  desc = "Search for dotfiles"
})
vim.keymap.set("n", "<leader>tb", '<cmd>Telescope buffers<cr>', {
  desc = "Search for buffer"
})

-- Mappings di nvim_tree
vim.keymap.set("n", "<leader>nt", '<cmd>NvimTreeToggle<cr>', {desc = "Toggle the tree"})
vim.keymap.set("n", "<leader>nf", '<cmd>NvimTreeFindFileToggle<cr>', {desc = "Toggle the findFileTree"})

-- Mappings di dap
-- Lancio debug del main
vim.keymap.set("n", "<leader>ds", '<cmd>lua require("dapui").open(1)<cr><cmd>lua require("dap").continue()<cr>', {desc = "Start debug"})
-- Continuo il programma
vim.keymap.set("n", "<leader>dc", '<cmd>lua require("dap").continue()<cr>', {desc = "Continue dap"})
-- Chiudo tutto
vim.keymap.set("n", "<leader>dd", '<cmd>lua require("dap").terminate()<cr><cmd>lua require("dapui").close()<cr>', {desc = "Terminate dap"})
vim.keymap.set("n", "<leader>db", '<cmd>lua require("dap").toggle_breakpoint()<cr>', {desc = "Toggle breakpoint"})
vim.keymap.set("n", "<leader>dr", '<cmd>lua require("dap").clear_breakpoints()<cr>', {desc = "clear breakpoints"})
vim.keymap.set("n", "<leader>do", '<cmd>lua require("dapui").toggle()<cr>', {desc = "toggle dapui"})

-- Mappings di Trouble
vim.keymap.set("n", "<leader>tt", '<cmd>TroubleToggle<cr>', {desc = "Toggle trouble"})
