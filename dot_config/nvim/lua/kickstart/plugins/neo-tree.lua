-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = function()
    local renderer = require 'neo-tree.ui.renderer'
    local indexOf = function(array, value)
      for i, v in ipairs(array) do
        if v == value then
          return i
        end
      end
      return nil
    end
    local getSiblings = function(state, node)
      local parent = state.tree:get_node(node:get_parent_id())
      local siblings = parent:get_child_ids()
      return siblings
    end
    local next_sibling = function(state)
      local node = state.tree:get_node()
      local siblings = getSiblings(state, node)
      if not node.is_last_child then
        local currentIndex = indexOf(siblings, node.id)
        local nextIndex = siblings[currentIndex + 1]
        renderer.focus_node(state, nextIndex)
      end
    end
    local prev_sibling = function(state)
      local node = state.tree:get_node()
      local siblings = getSiblings(state, node)
      local currentIndex = indexOf(siblings, node.id)
      if currentIndex > 1 then
        local nextIndex = siblings[currentIndex - 1]
        renderer.focus_node(state, nextIndex)
      end
    end
    local last_sibling = function(state)
      local tree = state.tree
      local node = tree:get_node()
      local siblings = tree:get_nodes(node:get_parent_id())
      renderer.focus_node(state, siblings[#siblings]:get_id())
    end
    local first_sibling = function(state)
      local tree = state.tree
      local node = tree:get_node()
      local siblings = tree:get_nodes(node:get_parent_id())
      renderer.focus_node(state, siblings[1]:get_id())
    end
    local focus_parent = function(state)
      local tree = state.tree
      local node = tree:get_node()
      renderer.focus_node(state, node:get_parent_id())
    end
    return {
      close_if_last_window = true,
      filesystem = {
        filtered_items = {
          visible = true,
        },
        window = {
          mappings = {
            ['\\'] = 'close_window',
            ['J'] = { next_sibling, desc = 'next_sibling' },
            ['K'] = { prev_sibling, desc = 'prev_sibling' },
            ['<C-j>'] = { last_sibling, desc = 'last_sibling' },
            ['<C-k>'] = { first_sibling, desc = 'first_sibling' },
            ['<C-p>'] = { focus_parent, desc = 'focus_parent' },
          },
        },
      },
    }
  end,
}
-- opts = {
--   close_if_last_window = true,
--   filesystem = {
--     filtered_items = {
--       visible = true,
--     },
--     window = {
--       mappings = {
--         ['\\'] = 'close_window',
--         ['J'] = { next_sibling, desc = 'next_sibling' },
--         ['K'] = { prev_sibling, desc = 'prev_sibling' },
--         -- Go to last sibling
--         ['<C-j>'] = function(state)
--           local tree = state.tree
--           local node = tree:get_node()
--           local siblings = tree:get_nodes(node:get_parent_id())
--           local renderer = require 'neo-tree.ui.renderer'
--           renderer.focus_node(state, siblings[#siblings]:get_id())
--         end,
--         -- Go to first sibling
--         ['<C-K>'] = function(state)
--           local tree = state.tree
--           local node = tree:get_node()
--           local siblings = tree:get_nodes(node:get_parent_id())
--           local renderer = require 'neo-tree.ui.renderer'
--           renderer.focus_node(state, siblings[1]:get_id())
--         end,
--       },
--     },
--   },
-- },
