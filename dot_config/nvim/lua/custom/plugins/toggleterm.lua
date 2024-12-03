return {
  'akinsho/toggleterm.nvim',
  config = function()
    require('toggleterm').setup {
      open_mapping = [[<c-\>]],
      shade_terminals = false,
      -- add --login so ~/.zprofile is loaded
      -- https://vi.stackexchange.com/questions/16019/neovim-terminal-not-reading-bash-profile/16021#16021
      shell = 'zsh --login',
      direction = 'float',
      float_opts = {
        border = 'curved',
      },
    }

    local Terminal = require('toggleterm.terminal').Terminal
    local lazygit = Terminal:new { cmd = 'lazygit', hidden = true, float_opts = { border = 'curved' } }

    function _lazygit_toggle()
      lazygit:toggle()
    end
  end,
  keys = {
    { [[<C-\>]] },
    { '<leader>0', '<Cmd>2ToggleTerm<Cr>', desc = 'Terminal #2' },
    { '<leader>gg', '<cmd>lua _lazygit_toggle()<CR>', desc = 'LazyGit popup' },
  },
}
