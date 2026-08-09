-- nvim-ts-autotag : ferme et renomme automatiquement les balises HTML/JSX/Vue
-- https://github.com/windwp/nvim-ts-autotag
--
-- Taper `<div>` insère `</div>` ; renommer la balise ouvrante met à jour la fermante.
-- Fonctionne via treesitter, donc le parser du langage doit être installé
-- (kickstart les installe à la volée à l'ouverture du fichier).

vim.pack.add { 'https://github.com/windwp/nvim-ts-autotag' }

require('nvim-ts-autotag').setup {
  opts = {
    enable_close = true, -- ferme la balise en tapant `>`
    enable_rename = true, -- renomme la balise appairée
    enable_close_on_slash = false, -- fermeture sur `</` (bruyant, désactivé)
  },
}
