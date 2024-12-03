return {
  'stevearc/aerial.nvim',
  opts = {
    attach_mode = 'global',
    backends = { 'lsp', 'treesitter', 'markdown', 'man' },
    show_guides = true,
    filter_kind = false,
    layout = {
      min_width = { 40, 0.2 },
      max_width = { 100, 0.4 },
      resize_to_content = false,
      win_opts = {
        winhl = 'Normal:NormalFloat,FloatBorder:NormalFloat,SignColumn:SignColumnSB',
        signcolumn = 'yes',
        statuscolumn = ' ',
      },
    },
      -- stylua: ignore
      guides = {
        mid_item   = "├╴",
        last_item  = "└╴",
        nested_top = "│ ",
        whitespace = "  ",
      },
  },
  keys = {
    { '<leader>cs', '<cmd>AerialToggle<cr>', desc = 'Aerial (Symbols)' },
  },
  -- Optional dependencies
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
}
