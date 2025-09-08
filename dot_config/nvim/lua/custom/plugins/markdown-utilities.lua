-- Using mini.surround custom surrounding that doubles the surround for `*`
vim.keymap.set('n', '<leader>mb', function()
  vim.cmd.normal 'saiw*'
end, { desc = '[M]arkdown: make bold' })
vim.keymap.set('n', '<leader>mi', function()
  vim.cmd.normal 'saiw_'
end, { desc = '[M]arkdown: make italic' })

return {}
