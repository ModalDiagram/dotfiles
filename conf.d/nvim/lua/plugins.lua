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

  ------------------------------ DEPENDENCIES --------------------------------
  -- search for them in the requires fields to see if they are still required
  use { "kyazdani42/nvim-web-devicons" }


  ---------------------------- COMPLETION --------------------------
  -- Snippet engine and snippet template
  use { "SirVer/ultisnips" }
  -- auto-completion engine
  use { "onsails/lspkind-nvim" }
  use { "hrsh7th/nvim-cmp", after = "lspkind-nvim", config = [[require('config.nvim-cmp')]] }

  -- nvim-cmp completion sources
  use { "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp" }
  use { "hrsh7th/cmp-path", after = "nvim-cmp" }
  use { "hrsh7th/cmp-buffer", after = "nvim-cmp" }
  use { "hrsh7th/cmp-omni", after = "nvim-cmp" }
  use { "hrsh7th/cmp-cmdline", after = "nvim-cmp" }
  use { "quangnguyen30192/cmp-nvim-ultisnips", after = { "nvim-cmp", "ultisnips" } }

  ------------------------------------ LSP -----------------------------------
  use { "neovim/nvim-lspconfig", config = [[require('config.lsp')]] }
  use {
    "nvimdev/lspsaga.nvim",
    config = [[require("config.lspsaga")]],
    requires = {
      {"nvim-tree/nvim-web-devicons"},
      {"nvim-treesitter/nvim-treesitter"}
    }
  }
  use { "folke/trouble.nvim", requires = "nvim-tree/nvim-web-devicons" }

  -- Extra LSP servers
  use { "mfussenegger/nvim-jdtls", after = "nvim-lspconfig", config = [[require('config.jdtls')]] }
  use { 'jalvesaq/Nvim-R' }

  -- Linter manager
  use { "jose-elias-alvarez/null-ls.nvim", config = [[require('config.null')]] }

  -- DAP manager
  use { 'mfussenegger/nvim-dap', config = [[require('config.dap')]] }
  use { "folke/neodev.nvim", config = [[require('config.neodev')]] }
  use { "nvim-neotest/nvim-nio" }
  use {
    "rcarriga/nvim-dap-ui",
    after = {"nvim-dap", "neodev.nvim"},
    requires = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
    config = [[require('config.dapui')]]
  }

  -- Treesitter for formatting
  use { "nvim-treesitter/nvim-treesitter", config = [[require('config.treesitter')]] }
  use { 'nvim-treesitter/playground' }
  use { "kiyoon/treesitter-indent-object.nvim"}

  use { "rcarriga/nvim-notify", config = [[require('config.notify')]] }
  -- Plugin to manipulate character pairs quickly
  use { "machakann/vim-sandwich" }

  ------------------------------ FILE AND TEXT MOVEMENT ---------------------
  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} },
    config = [[require("config.telescope")]]
  }

  -- Searching with fzf
  use { "Yggdroot/LeaderF", cmd = "Leaderf", run = ":LeaderfInstallCExtension" }

  -- File explorer
  use {
    "kyazdani42/nvim-tree.lua",
    requires = { "kyazdani42/nvim-web-devicons" },
    config = [[require('config.nvim-tree')]],
  }

  -- Projects manager
  use {
    "ahmedkhalf/project.nvim", config = [[require('config.project')]]
  }

  -- Moving by typing the first 2 letters
  use { 'ggandor/leap.nvim', config=[[require('config.leap')]]}
  -- Moving by context (di( to delete inside the parantheses)
  use { "wellle/targets.vim" }

  ---------------------------- UTILITIES --------------------------------------
  -- Git plugins
  use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim', config = [[require('config.neogit')]], tag = "v0.0.1" }
  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim', config = [[require('config.diffview')]] }

  -- show and trim trailing whitespaces
  use { "jdhao/whitespace.nvim" }

  -- Yank and put plugin
  use { "gbprod/yanky.nvim", after = "telescope.nvim", config = [[require('config.yanky')]] }

  -- Comment plugin
  use { "tpope/vim-commentary" }

  -- Markdown preview
  use({ "iamcco/markdown-preview.nvim", run = "cd app && npm install", setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" }, })
  use { "simnalamburt/vim-mundo", cmd = { "MundoToggle", "MundoShow" } }

  -- Showing keybindings
  use {
    "folke/which-key.nvim",
    config = function()
      vim.defer_fn(function()
        require("config.which-key")
      end, 2000)
    end,
  }
  -- Automatic insertion and deletion of a pair of characters
  use {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
        require("nvim-autopairs").setup {}
    end
  }

  -- Highlight URLs inside vim
  use { "itchyny/vim-highlighturl" }

  -- Show line with indent level
  use { "lukas-reineke/indent-blankline.nvim", after={"treesitter-indent-object.nvim"}, config = [[require("config.indent")]]}

  ----------------------------- APPEARANCES -----------------------------------
  use { "akinsho/bufferline.nvim", config = [[require('config.bufferline')]] }

  use {
    "nvim-lualine/lualine.nvim",
    config = [[require('config.statusline')]],
  }
  -- fancy start screen
  use { "glepnir/dashboard-nvim",
    config = [[require('config.dashboard-nvim')]]
  }
  use { 'simeji/winresizer' }


  use { 'lambdalisue/suda.vim' }

  ------------------------------- COLORS --------------------------------------
  use({ 'rose-pine/neovim', as = 'rose-pine' })
  use { "Tsuzat/NeoSolarized.nvim"}
  -- Highlight colors in CSS files
  use { 'brenoprata10/nvim-highlight-colors' }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end

end)
