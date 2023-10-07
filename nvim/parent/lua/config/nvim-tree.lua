local nvim_tree = require("nvim-tree")

require('telescope').load_extension('projects')

local function on_attach(bufnr)
  local map = vim.keymap
  local api = require('nvim-tree.api')
  local diagnostics = require("nvim-tree.diagnostics")

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end


  -- MODIFIED
  map.set('n', '<C-d>', api.tree.change_root_to_node,          opts('CD'))
  map.set('n', '<C-k>', api.node.navigate.parent,              opts('Parent directory'))
  map.set('n', '<C-j>', api.node.navigate.sibling.last,        opts('Last Sibling'))

  -- DEFAULT
  map.set('n', '<C-e>', api.node.open.replace_tree_buffer,     opts('Open: In Place'))
  map.set('n', '<C-r>', api.fs.rename_sub,                     opts('Rename: Omit Filename'))
  map.set('n', '<C-t>', api.node.open.tab,                     opts('Open: New Tab'))
  map.set('n', '<C-v>', api.node.open.vertical,                opts('Open: Vertical Split'))
  map.set('n', '<C-x>', api.node.open.horizontal,              opts('Open: Horizontal Split'))
  map.set('n', '<BS>',  api.node.navigate.parent_close,        opts('Close Directory'))
  map.set('n', '<CR>',  api.node.open.edit,                    opts('Open'))
  map.set('n', '<Tab>', api.node.open.preview,                 opts('Open Preview'))
  map.set('n', '>',     api.node.navigate.sibling.next,        opts('Next Sibling'))
  map.set('n', '<',     api.node.navigate.sibling.prev,        opts('Previous Sibling'))
  map.set('n', '.',     api.node.run.cmd,                      opts('Run Command'))
  map.set('n', '-',     api.tree.change_root_to_parent,        opts('Up'))
  map.set('n', 'a',     api.fs.create,                         opts('Create'))
  map.set('n', 'bmv',   api.marks.bulk.move,                   opts('Move Bookmarked'))
  map.set('n', 'B',     api.tree.toggle_no_buffer_filter,      opts('Toggle No Buffer'))
  map.set('n', 'c',     api.fs.copy.node,                      opts('Copy'))
  map.set('n', 'C',     api.tree.toggle_git_clean_filter,      opts('Toggle Git Clean'))
  map.set('n', '[c',    api.node.navigate.git.prev,            opts('Prev Git'))
  map.set('n', ']c',    api.node.navigate.git.next,            opts('Next Git'))
  map.set('n', 'd',     api.fs.remove,                         opts('Delete'))
  map.set('n', 'D',     api.fs.trash,                          opts('Trash'))
  map.set('n', 'E',     api.tree.expand_all,                   opts('Expand All'))
  map.set('n', 'e',     api.fs.rename_basename,                opts('Rename: Basename'))
  map.set('n', ']e',    api.node.navigate.diagnostics.next,    opts('Next Diagnostic'))
  map.set('n', '[e',    api.node.navigate.diagnostics.prev,    opts('Prev Diagnostic'))
  map.set('n', 'F',     api.live_filter.clear,                 opts('Clean Filter'))
  map.set('n', 'f',     api.live_filter.start,                 opts('Filter'))
  map.set('n', 'g?',    api.tree.toggle_help,                  opts('Help'))
  map.set('n', 'gy',    api.fs.copy.absolute_path,             opts('Copy Absolute Path'))
  map.set('n', 'H',     api.tree.toggle_hidden_filter,         opts('Toggle Dotfiles'))
  map.set('n', 'I',     api.tree.toggle_gitignore_filter,      opts('Toggle Git Ignore'))
  map.set('n', 'J',     api.node.navigate.sibling.last,        opts('Last Sibling'))
  map.set('n', 'K',     api.node.navigate.sibling.first,       opts('First Sibling'))
  map.set('n', 'm',     api.marks.toggle,                      opts('Toggle Bookmark'))
  map.set('n', 'o',     api.node.open.edit,                    opts('Open'))
  map.set('n', 'O',     api.node.open.no_window_picker,        opts('Open: No Window Picker'))
  map.set('n', 'p',     api.fs.paste,                          opts('Paste'))
  map.set('n', 'P',     api.node.navigate.parent,              opts('Parent Directory'))
  map.set('n', 'q',     api.tree.close,                        opts('Close'))
  map.set('n', 'r',     api.fs.rename,                         opts('Rename'))
  map.set('n', 'R',     api.tree.reload,                       opts('Refresh'))
  map.set('n', 's',     api.node.run.system,                   opts('Run System'))
  map.set('n', 'S',     api.tree.search_node,                  opts('Search'))
  map.set('n', 'U',     api.tree.toggle_custom_filter,         opts('Toggle Hidden'))
  map.set('n', 'W',     api.tree.collapse_all,                 opts('Collapse'))
  map.set('n', 'x',     api.fs.cut,                            opts('Cut'))
  map.set('n', 'y',     api.fs.copy.filename,                  opts('Copy Name'))
  map.set('n', 'Y',     api.fs.copy.relative_path,             opts('Copy Relative Path'))
  map.set('n', '<2-LeftMouse>',  api.node.open.edit,           opts('Open'))
  map.set('n', '<2-RightMouse>', api.tree.change_root_to_node, opts('CD'))
  -- END_DEFAULT_ON_ATTACH
end

nvim_tree.setup {
  on_attach = on_attach,
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = true
  },
  auto_reload_on_write = true,
  disable_netrw = false,
  hijack_cursor = false,
  hijack_netrw = true,
  hijack_unnamed_buffer_when_opening = false,
  open_on_tab = false,
  sort_by = "name",
  update_cwd = false,
  view = {
    width = 30,
    side = "left",
    preserve_window_proportions = false,
    number = false,
    relativenumber = false,
    signcolumn = "yes",
  },
  renderer = {
    indent_markers = {
      enable = false,
      icons = {
        corner = "└ ",
        edge = "│ ",
        none = "  ",
      },
    },
    icons = {
      webdev_colors = true,
    },
  },
  hijack_directories = {
    enable = true,
    auto_open = true,
  },
  system_open = {
    cmd = "",
    args = {},
  },
  diagnostics = {
    enable = false,
    show_on_dirs = false,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  },
  filters = {
    dotfiles = false,
    custom = {},
    exclude = {},
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 400,
  },
  actions = {
    use_system_clipboard = true,
    change_dir = {
      enable = true,
      global = false,
      restrict_above_cwd = false,
    },
    open_file = {
      quit_on_open = false,
      resize_window = false,
      window_picker = {
        enable = true,
        chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
        exclude = {
          filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
          buftype = { "nofile", "terminal", "help" },
        },
      },
    },
  },
  trash = {
    cmd = "trash",
    require_confirm = true,
  },
  log = {
    enable = false,
    truncate = false,
    types = {
      all = false,
      config = false,
      copy_paste = false,
      diagnostics = false,
      git = false,
      profile = false,
    },
  },
}


local api = require("nvim-tree.api")
api.events.subscribe(api.events.Event.FileCreated, function(file)
  vim.cmd("edit " .. file.fname)
  -- if vim.bo.filetype == 'java' then
  --   vim.cmd("call Insert_java()")
  -- end
  vim.cmd("call Insert()")
end)
