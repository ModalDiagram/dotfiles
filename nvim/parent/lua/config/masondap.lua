local dap = require("dap")

require("mason-nvim-dap").setup({
  handlers = {
    function(source_name)
      -- all sources with no handler get passed here


      -- Keep original functionality of `automatic_setup = true`
      require('mason-nvim-dap.automatic_setup')(source_name)
    end,
    python = function(source_name)
        dap.adapters.python = {
          type = 'executable';
          command = '/home/sandro0198/.local/share/nvim/mason/packages/debugpy/venv/bin/python';
          args = { '-m', 'debugpy.adapter' };
        }
        dap.configurations.python = {
          {
            name = "Launch with integratedTerminal";
            console = "integratedTerminal";
            request = "launch";
            program = "${file}";
            type = "python";
            pythonPath = "python";
          },
          {
            name = "Launch with arguments";
            console = "integratedTerminal";
            request = "launch";
            program = "${file}";
            type = "python";
            pythonPath = "python";
            args = function()
              local args_string = vim.fn.input("Arguments: ")
              return vim.split(args_string, " ")
            end;
          }
        }
    end,
  },
})
-- require 'mason-nvim-dap'.setup_handlers {
--     function(source_name)
--       -- all sources with no handler get passed here


--       -- Keep original functionality of `automatic_setup = true`
--       require('mason-nvim-dap.automatic_setup')(source_name)
--     end,
--     python = function(source_name)
--         dap.adapters.python = {
--           type = 'executable';
--           command = '/home/sandro0198/.local/share/nvim/mason/packages/debugpy/venv/bin/python';
--           args = { '-m', 'debugpy.adapter' };
--         }
--         dap.configurations.python = {
--           {
--             name = "Launch with integratedTerminal";
--             console = "integratedTerminal";
--             request = "launch";
--             program = "${file}";
--             type = "python";
--             pythonPath = "python";
--           },
--         }
--     end,
-- }


