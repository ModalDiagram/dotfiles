-- Questa configurazione sostituisce jdtls di mason.
-- Al suo posto uso il plugin e il suo dap. Forse c'è da mettere after nvim-dap nei plugins


vim.keymap.set("n", "<leader>dt", '<cmd>lua require("jdtls").test_class()<cr><cmd>lua require("dapui").open(2)<cr>', {desc = "test class"})
-- Cerco la directory del progetto per avere un workspace per progetto
local root_markers = { "gradlew", "mvnw", ".git", ".gitignore", "pom.xml", "build.gradle", ".idea" }
local root_dir = require("jdtls.setup").find_root(root_markers)
local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')

-- Vedo se esiste una configurazione specifica nella root dir e in caso la carico
-- local personal_config = root_dir .. "/jdtls_config.lua"
-- local f = io.open(personal_config, "r")
-- local my_settings = {}
-- local config_found = false
-- if f ~= nil then
--   my_settings = loadfile(personal_config)()
--   config_found = true
--   -- print(vim.inspect(table.settings))
--   -- local prova['a'] = table.settings
--   -- print(vim.inspect(prova))
--   -- print("trovata config del progetto")
-- end

-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  cmd = {

    -- 💀
    'java', -- or '/path/to/java17_or_newer/bin/java'
            -- depends on if `java` is in your $PATH env variable and if it points to the right version.

    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

    -- 💀
    '-jar', '/home/sandro0198/altre_app/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',
         -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
         -- Must point to the                                                     Change this to
         -- eclipse.jdt.ls installation                                           the actual version


    -- 💀
    '-configuration', '/home/sandro0198/altre_app/jdtls/config_linux/',
                    -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
                    -- Must point to the                      Change to one of `linux`, `win` or `mac`
                    -- eclipse.jdt.ls installation            Depending on your system.


    -- 💀
    -- See `data directory configuration` section in the README
    '-data', '/home/sandro0198/altre_app/jdtls/workspace/' .. project_name,
  },

  -- 💀
  -- This is the default if not provided, you can remove it. Or adjust as needed.
  -- One dedicated LSP server & client will be started per unique root_dir
  root_dir = root_dir,

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
  --   java = {
  --     project = {
  --       referencedLibraries = {
  --         '/home/sandro0198/Downloads/postgresql-42.5.4.jar'
  --       },
  --     },
  --   }
  },

  -- Language server `initializationOptions`
  -- You need to extend the `bundles` with paths to jar files
  -- if you want to use additional eclipse.jdt.ls plugins.
  --
  -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
  --
  -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
  init_options = {
    bundles = {}
  },
}

-- if a config was found, this adds its (settings) contents to the config
if config_found then
  for k, v in pairs(my_settings.settings) do
    -- print(k, v)
    config['settings'][k] = v
  end
end



local extendedClientCapabilities = require'jdtls'.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
-- SETUP DEL DAP
config['init_options'] = {
  extendedClientCapabilities = extendedClientCapabilities;
  bundles = {
    vim.fn.glob("/home/sandro0198/altre_app/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-0.44.0.jar", 1)
  };
}
-- print(vim.inspect(config))
config['on_attach'] = function(client, bufnr)
  -- With `hotcodereplace = 'auto' the debug adapter will try to apply code changes
  -- you make during a debug session immediately.
  -- Remove the option if you do not want that.
  -- You can use the `JdtHotcodeReplace` command to trigger it manually
  require('jdtls').setup_dap({ hotcodereplace = 'auto' })
end
-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require('jdtls').start_or_attach(config)
