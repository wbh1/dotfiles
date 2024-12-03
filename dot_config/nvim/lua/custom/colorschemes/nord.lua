return { -- You can easily change to a different colorscheme.
  -- Change the name of the colorscheme plugin below, and then
  -- change the command in the config to whatever the name of that colorscheme is.
  --
  -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
  'shaunsingh/nord.nvim',
  priority = 1000, -- Make sure to load this before all the other start plugins.
  init = function()
    -- Load the colorscheme here.
    -- vim.cmd.colorscheme 'nord'

    -- You can configure highlights by doing something like:
    vim.cmd.hi 'Comment gui=none'
    vim.cmd.hi 'MatchParen guifg=#a3be8c'
  end,
}
