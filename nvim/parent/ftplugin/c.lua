vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end


-- vim.api.nvim_create_autocmd({ "User targets#mappings#user" }, {
--   callback = function()
--     vim.cmd("call targets#mappings#extend({';': {'argument': [{'o': '[([]', 'c': '[])]', 's': ';'}]},})")
--   end,
-- })
