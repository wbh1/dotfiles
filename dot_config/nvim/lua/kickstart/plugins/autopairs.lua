-- autopairs
-- https://github.com/windwp/nvim-autopairs
-- TODO: Use mini.pairs ?

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  -- Optional dependency
  dependencies = { 'hrsh7th/nvim-cmp' },
  config = function()
    require('nvim-autopairs').setup {}
    -- If you want to automatically add `(` after selecting a function or method
    local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
    local cmp = require 'cmp'
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
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
