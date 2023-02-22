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
dap.configurations.python = {
  {
    name = "Launch with integratedTerminal";
    console = "integratedTerminal";
    request = "launch";
    program = "${file}";
    type = "python";
    pythonPath = "python";
  },
}

dap.defaults.fallback.terminal_win_cmd = 'tabnew'
