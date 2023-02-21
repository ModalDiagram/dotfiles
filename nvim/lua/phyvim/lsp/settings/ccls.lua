return {
  init_options = {
    -- compilationDatabaseDirectory = "build";
    -- index = {
    --   threads = 0;
    -- };
    clang = {
      --excludeArgs = { "-frounding-math"} ;
      extraArgs = {"--gcc-toolchain=/usr/bin/gcc"};
    }
  single_file_support = true;
  };
  -- settings = {

  --   python = {
  --     analysis = {
  --       typeCheckingMode = "off",
  --       autoImportCompletion = true,
  --     },
  --   },
  -- },
}
