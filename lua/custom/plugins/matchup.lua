-- vim-matchup : navigation étendue entre paires avec `%`
-- https://github.com/andymass/vim-matchup

-- NOTE: les variables `g:` de vim-matchup doivent être définies AVANT que le plugin
-- ne soit sourcé, donc avant l'appel à `vim.pack.add`.
vim.g.matchup_matchparen_offscreen = { method = 'popup' }

vim.pack.add { 'https://github.com/andymass/vim-matchup' }
