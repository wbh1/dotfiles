-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny
lvim.plugins = {
  {
    "shaunsingh/nord.nvim",
  },

}
lvim.colorscheme = "nord"
lvim.format_on_save.enabled = true
lvim.builtin.telescope.defaults.sorting_strategy = "ascending"

-- require("nvim-tree").setup {
--   live_filter = {
--     prefix = "[FILTER]: ",
--     always_show_folders = false,
--   }
-- }
