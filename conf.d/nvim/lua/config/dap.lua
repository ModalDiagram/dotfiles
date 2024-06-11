require('dap.ext.vscode').load_launchjs()

local dap = require('dap')

dap.configurations.java = {
  {
    type = 'java';
    request = 'launch';
    name = "Launch file";
    program = "${file}";
    pythonPath = function()
      return '/usr/bin/java'
    end;
  },
}
dap.adapters.python = {
  type = 'executable';
  -- command = '/home/sandro0198/.local/share/nvim/mason/packages/debugpy/venv/bin/python';
  command = 'python';
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

dap.adapters.lldb = {
    type = "executable",
    command = "lldb-vscode", -- adjust as needed
    name = "lldb",
}

dap.configurations.rust = {
    {
        name = "frip",
        type = "lldb",
        request = "launch",
        console = "integratedTerminal";
        program = function()
            return vim.fn.getcwd() .. "/target/debug/frip"
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    },
    {
        name = "hello-dap",
        type = "lldb",
        request = "launch",
        program = function()
            return vim.fn.getcwd() .. "/target/debug/hello-dap"
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    },
}

dap.defaults.fallback.terminal_win_cmd = 'tabnew'
