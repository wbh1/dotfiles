return {
  'EdenEast/nightfox.nvim',
  priority = 1000, -- Make sure to load this before all the other start plugins.
  config = function()
    require('nightfox').setup {
      options = {
        colorblind = {
          enable = true, -- Enable colorblind support
          simulate_only = false, -- Only show simulated colorblind colors and not diff shifted
          severity = {
            protan = 0.2, -- Severity [0,1] for protan (red)
            deutan = 0, -- Severity [0,1] for deutan (green)
            tritan = 0, -- Severity [0,1] for tritan (blue)
          },
        },
      },
    }
    vim.cmd.colorscheme 'nordfox'
  end,
}
