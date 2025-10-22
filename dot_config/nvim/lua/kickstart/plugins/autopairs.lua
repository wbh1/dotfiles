-- autopairs
-- https://github.com/windwp/nvim-autopairs
-- TODO: Use mini.pairs ?

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  config = function()
    require('nvim-autopairs').setup {}
    local np = require 'nvim-autopairs'
    local Rule = require 'nvim-autopairs.rule'
    local cond = require 'nvim-autopairs.conds'

    -- https://github.com/windwp/nvim-autopairs/issues/478#issuecomment-2543315927
    np.add_rules {
      Rule('*', '*', { 'markdown' }):with_pair(cond.not_before_regex '\n'),
      Rule('_', '_', { 'markdown' }):with_pair(cond.before_regex '%s'),
    }
  end,
}
