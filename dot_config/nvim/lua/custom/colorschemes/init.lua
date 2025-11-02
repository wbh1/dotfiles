-- Check if omarchy theme exists
local omarchy_theme_path = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")
local theme

-- if vim.fn.filereadable(omarchy_theme_path) == 1 then
--   -- Load the omarchy theme if it exists
--   theme = dofile(omarchy_theme_path)
-- else
--   -- Fall back to default theme
--   theme = require 'custom.colorschemes.nightfox'
--   -- local theme = require 'custom.colorschemes.nord';
-- end

theme = require("custom.colorschemes.nightfox")
return { theme }
