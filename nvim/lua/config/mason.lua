require("mason").setup()
require("neodev").setup()
require("mason-lspconfig").setup()

local servers = {
  jdtls = {
    Java = {
      cmd = {
        "-data",
        "/home/sandro0198/IdeaProjects/",
      },
    },
  },

  sumneko_lua = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}-- forse devo inizializzare le capabilities con make_capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()
require("mason-lspconfig").setup_handlers {
      -- a dedicated handler.
      function (server_name) -- default handler (optional)
        if server_name ~= "jdtls" then
          require("lspconfig")[server_name].setup {
            capabilities = capabilities,
            settings = servers[server_name],
          }
       end
      end,
    -- You can also specify a handler for a specific server
    }

