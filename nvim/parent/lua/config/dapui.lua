local dapui = require("dapui")

dapui.setup({
    active = true,
    on_config_done = nil,
    breakpoint = {
      text = "",
      texthl = "DiagnosticSignError",
      linehl = "",
      numhl = "",
    },
    breakpoint_rejected = {
      text = "",
      texthl = "DiagnosticSignError",
      linehl = "",
      numhl = "",
    },
    stopped = {
      text = "",
      texthl = "DiagnosticSignWarn",
      linehl = "Visual",
      numhl = "DiagnosticSignWarn",
    },
    log = {
      level = "info",
    },
    layouts = { {
      elements = {
        {
          id = "scopes",
          size = 0.2
        }, {
          id = "breakpoints",
          size = 0.1
        }, {
          id = "watches",
          size = 0.2
        }, {
          id = "console",
          size = 0.5
        } },
        position = "right",
        size = 60,
        id = 1
    }, {
      elements = {
        {
          id = "scopes",
          size = 0.3
        }, {
          id = "console",
          size = 0.3
        }, {
          id = "repl",
          size = 0.4
        } },
        position = "right",
        size = 60,
        id = 2
    }, },
  })
