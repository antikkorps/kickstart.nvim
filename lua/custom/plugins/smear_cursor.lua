-- smear-cursor.nvim : traînée animée derrière le curseur
-- https://github.com/sphamba/smear-cursor.nvim

vim.pack.add { 'https://github.com/sphamba/smear-cursor.nvim' }

require('smear_cursor').setup {
  -- Options par défaut. Quelques réglages utiles si besoin :
  -- stiffness = 0.8,
  -- trailing_stiffness = 0.5,
  -- smear_between_buffers = true,
  -- smear_between_neighbor_lines = true,
}
