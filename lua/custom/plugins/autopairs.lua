-- nvim-autopairs est activé par `require 'kickstart.plugins.autopairs'` (init.lua, SECTION 10),
-- qui l'installe avec les options par défaut.
--
-- On rappelle ici `setup` uniquement pour réactiver `check_ts`, présent dans l'ancienne
-- config : treesitter est alors consulté avant d'insérer une paire, ce qui évite les
-- fermetures parasites à l'intérieur des chaînes et des commentaires.

require('nvim-autopairs').setup { check_ts = true }
