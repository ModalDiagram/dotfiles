local api = vim.api
local fn = vim.fn

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Load packer.nvim
vim.cmd("packadd packer.nvim")

return require('packer').startup(function(use)
 -- -- it is recommended to put impatient.nvim before any other plugins
  use { "lewis6991/impatient.nvim", config = [[require('impatient')]] }

  use { "wbthomason/packer.nvim" }
  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} },
    config = [[require("config.telescope")]]
  }
  -- Colorchemes
  use({ 'rose-pine/neovim', as = 'rose-pine' })
  use { 'brenoprata10/nvim-highlight-colors' }
  -- Highlight URLs inside vim
  use { "itchyny/vim-highlighturl" }
  use { "lukas-reineke/indent-blankline.nvim", after={"treesitter-indent-object.nvim"}, config = [[require("config.indent")]]}


  -- showing keybindings
  use {
   "folke/which-key.nvim",
   config = function()
    vim.defer_fn(function()
      require("config.which-key")
    end, 2000)
  end,
  }
  -- Automatic insertion and deletion of a pair of characters
  use { "Raimondi/delimitMate" }

  -- show and trim trailing whitespaces
  use { "jdhao/whitespace.nvim" }
  -- Yank and put plugin
  use { "gbprod/yanky.nvim", after = "telescope.nvim", config = [[require('config.yanky')]] }
  -- Comment plugin
  use { "tpope/vim-commentary" }
  -- Markdown preview
  use({ "iamcco/markdown-preview.nvim", run = "cd app && yarn install", setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" }, })
  use { "kyazdani42/nvim-web-devicons" }
  -- file explorer
  use {
    "kyazdani42/nvim-tree.lua",
    requires = { "kyazdani42/nvim-web-devicons" },
    config = [[require('config.nvim-tree')]],
  }
  use {
    "nvim-lualine/lualine.nvim",
    config = [[require('config.statusline')]],
  }
  -- Show match number and index for searching
  use {
    "kevinhwang91/nvim-hlslens",
    branch = "main",
    keys = { { "n", "*" }, { "n", "#" }, { "n", "n" }, { "n", "N" } },
    config = [[require('config.hlslens')]],
  }
  -- Show undo history visually
  use { "simnalamburt/vim-mundo", cmd = { "MundoToggle", "MundoShow" } }

  ----------------------------------------Snippet e completion--------------------------
  use { "onsails/lspkind-nvim" }
  -- Snippet engine and snippet template
  use { "SirVer/ultisnips" }
  -- auto-completion engine
  use { "hrsh7th/nvim-cmp", after = "lspkind-nvim", config = [[require('config.nvim-cmp')]] }
  -- nvim-cmp completion sources
  use { "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp" }
  use { "hrsh7th/cmp-path", after = "nvim-cmp" }
  use { "hrsh7th/cmp-buffer", after = "nvim-cmp" }
  use { "hrsh7th/cmp-omni", after = "nvim-cmp" }
  use { "hrsh7th/cmp-cmdline", after = "nvim-cmp" }
  use { "quangnguyen30192/cmp-nvim-ultisnips", after = { "nvim-cmp", "ultisnips" } }
  -- Mason gestisce LSP, DAP, linter e formatter
  use { "williamboman/mason.nvim", after = "nvim-cmp", config = [[require('config.mason')]] }
  -- Gestori di LSP
  use { "williamboman/mason-lspconfig.nvim" }
  use { "neovim/nvim-lspconfig", config = [[require('config.lsp')]] }
  use({
      "glepnir/lspsaga.nvim",
      config = [[require("config.lspsaga")]],
      requires = {
          {"nvim-tree/nvim-web-devicons"},
          --Please make sure you install markdown and markdown_inline parser
          {"nvim-treesitter/nvim-treesitter"}
      }
  })
  use { "mfussenegger/nvim-jdtls", after = "nvim-lspconfig", config = [[require('config.jdtls')]] }
  -- Gestori di linter
  use { "jose-elias-alvarez/null-ls.nvim", config = [[require('config.null')]] }
  use { "jay-babu/mason-null-ls.nvim", after = "null-ls.nvim", config = [[require('config.masonnull')]]}
  -- Gestore di dap
  use { "jay-babu/mason-nvim-dap.nvim", after = "mason.nvim", config = [[require('config.masondap')]] }
  use { 'mfussenegger/nvim-dap', config = [[require('config.dap')]] }
  use { "folke/neodev.nvim", config = [[require('config.neodev')]] }
  use { "rcarriga/nvim-dap-ui", after = {"nvim-dap", "neodev.nvim"}, requires = {"mfussenegger/nvim-dap"}, config = [[require('config.dapui')]] }
  -- Treesitter per gli highlight
  use { "nvim-treesitter/nvim-treesitter",config = [[require('config.treesitter')]] }
  use { 'nvim-treesitter/playground' }
  use { "kiyoon/treesitter-indent-object.nvim"}

  use { "rcarriga/nvim-notify", config = [[require('config.notify')]] }
  -- Plugin to manipulate character pairs quickly
  use { "machakann/vim-sandwich" }
  -- Additional powerful text object for vim, this plugin should be studied
  -- carefully to use its full power
  use { "wellle/targets.vim" }
  -- Lista degli errori
  use {
    "folke/trouble.nvim",
    requires = "nvim-tree/nvim-web-devicons",
    config = function()
      require("trouble").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  }
  -- Per cercare con telescope varie cose
  use { "Yggdroot/LeaderF", cmd = "Leaderf", run = ":LeaderfInstallCExtension" }

  use { "akinsho/bufferline.nvim", config = [[require('config.bufferline')]] }

  -- fancy start screen
  use { "glepnir/dashboard-nvim",
    config = [[require('config.dashboard-nvim')]]
  }
  -- Gestore dei progetti
  use {
    "ahmedkhalf/project.nvim", config = [[require('config.project')]]
  }

  -- Plugins di git
  use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim', config = [[require('config.neogit')]] }
  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim', config = [[require('config.diffview')]] }

  use { 'ggandor/leap.nvim', config=[[require('config.leap')]]}
  use { 'subnut/nvim-ghost.nvim' }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end

end)
