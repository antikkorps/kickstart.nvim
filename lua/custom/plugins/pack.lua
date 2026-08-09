-- Confort autour de `vim.pack` (le gestionnaire de plugins intégré à Neovim),
-- qui n'a pas d'UI type `:Lazy`. Voir `:help vim.pack`.
--
-- Dans le buffer ouvert par une mise à jour : `:write` applique, `:quit` annule.

-- :Pack — état des plugins, sans accès réseau
vim.api.nvim_create_user_command('Pack', function() vim.pack.update(nil, { offline = true }) end, { desc = 'Plugins : état actuel (hors ligne)' })

-- :PackUpdate — récupère les mises à jour depuis GitHub
vim.api.nvim_create_user_command('PackUpdate', function() vim.pack.update() end, { desc = 'Plugins : chercher les mises à jour' })

-- :PackClean — supprime les plugins présents sur le disque mais plus dans la config.
-- `vim.pack` ne fait pas ce ménage tout seul, contrairement à lazy.nvim.
vim.api.nvim_create_user_command('PackClean', function()
  local stale = {}
  for _, plugin in ipairs(vim.pack.get()) do
    if not plugin.active then table.insert(stale, plugin.spec.name) end
  end

  if #stale == 0 then
    vim.notify('Aucun plugin à supprimer.', vim.log.levels.INFO)
    return
  end

  local prompt = ('Supprimer %d plugin(s) ?\n  %s'):format(#stale, table.concat(stale, '\n  '))
  if vim.fn.confirm(prompt, '&Oui\n&Non', 2) == 1 then
    vim.pack.del(stale)
    vim.notify(('%d plugin(s) supprimé(s).'):format(#stale), vim.log.levels.INFO)
  end
end, { desc = 'Plugins : supprimer ceux qui ne sont plus dans la config' })

-- Raccourcis, visibles dans which-key en appuyant sur <leader> puis `p`
vim.keymap.set('n', '<leader>pp', '<cmd>Pack<cr>', { desc = '[P]lugins : état' })
vim.keymap.set('n', '<leader>pu', '<cmd>PackUpdate<cr>', { desc = '[P]lugins : [U]pdate' })
vim.keymap.set('n', '<leader>pc', '<cmd>PackClean<cr>', { desc = '[P]lugins : [C]lean' })
