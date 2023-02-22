local null_ls = require("null-ls")


null_ls.setup({
  sources = {
    null_ls.builtins.diagnostics.pylint.with({
      extra_args = {}
    }),
    null_ls.builtins.diagnostics.luacheck.with({}),
  }
})
