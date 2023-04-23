local null_ls = require 'null-ls'

require ('mason-null-ls').setup({
})

-- require ('mason-null-ls').setup_handlers {
--     function(source_name, methods)
--       -- all sources with no handler get passed here

--       -- To keep the original functionality of `automatic_setup = true`,
--       -- please add the below.
--       require("mason-null-ls.automatic_setup")(source_name, methods)
--     end,
-- }

-- will setup any installed and configured sources above
null_ls.setup()
