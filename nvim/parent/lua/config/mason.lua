require("mason").setup()
require("neodev").setup()
require("mason-lspconfig").setup()

local servers = {
  pylint = {
    Python = {
      pythonPath = "",
    },
  },
}-- forse devo inizializzare le capabilities con make_capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Lo metto prima perche' altrimenti non si chiude quando cambio line
vim.api.nvim_create_autocmd("CursorHold", {
  buffer = bufnr,
  callback = function()
    vim.cmd("Lspsaga show_line_diagnostics ++unfocus")
  end,
})

local function my_on_attach(client, bufnr)
  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_autocmd("CursorHold", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.document_highlight()
      end,
    })

    vim.api.nvim_create_autocmd("CursorMoved" , {
      buffer = bufnr,
      callback = function ()
        vim.lsp.buf.clear_references()
      end
    })
  end
end
require("mason-lspconfig").setup_handlers {
      -- a dedicated handler.
      function (server_name) -- default handler (optional)
        if server_name ~= "jdtls" then
          require("lspconfig")[server_name].setup {
            capabilities = capabilities,
            settings = servers[server_name],
            on_attach = my_on_attach
          }
       end
      end,
    -- You can also specify a handler for a specific server
    }

