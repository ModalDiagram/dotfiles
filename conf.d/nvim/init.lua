-- This is my personal Nvim configuration supporting Mac, Linux and Windows, with various plugins configured.
-- This configuration evolves as I learn more about Nvim and become more proficient in using Nvim.
-- Since it is very long (more than 1000 lines!), you should read it carefully and take only the settings that suit you.
-- I would not recommend cloning this repo and replace your own config. Good configurations are personal,
-- built over time with a lot of polish.
--
-- Author: Jie-dong Hao
-- Email: jdhao@hotmail.com
-- Blog: https://jdhao.github.io/

local api = vim.api

require("plugins")

local core_conf_files = {
  "globals.vim", -- some global settings
  "mappings.lua", -- mappings
  "colorschemes.lua", -- imposto il mio colorscheme
  "plugins.vim", -- plugin installati
  "autocommands.vim",
  "functions.vim",
}

-- source all the core config files
for _, name in ipairs(core_conf_files) do
  local path = string.format("%s/core/%s", vim.fn.stdpath("config"), name)
  local source_cmd = "source " .. path
  vim.cmd(source_cmd)
end
