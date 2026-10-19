-- ABOUTME: Configures Go language tooling and save-time formatting.
-- ABOUTME: Sets up the Go plugin and its buffer-local integrations.
return {
  "ray-x/go.nvim",
  dependencies = { -- optional packages
    "ray-x/guihua.lua",
    "neovim/nvim-lspconfig",
    -- { "nvim-treesitter/nvim-treesitter", branch = 'main' } -- optional for master version
  },
  opts = function()
    require("go").setup(opts)
    local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.go",
      callback = function()
        if not vim.g.disable_autoformat then
          require('go.format').goimports()
        end
      end,
      group = format_sync_grp,
    })
    return {
      -- lsp_keymaps = false,
      -- other options
    }
  end,
  event = { "CmdlineEnter" },
  ft = { "go", 'gomod' },
  build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
}
