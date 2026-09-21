-- render-markdown.nvim : rendu du markdown dans le tampon (tableaux alignés,
-- titres, listes, blocs de code) — sans jamais modifier le fichier sur disque.
-- https://github.com/MeanderingProgrammer/render-markdown.nvim
--
-- Motivation : les fiches du memento sont pleines de tableaux dont les pipes ne
-- sont pas alignés à la main. En markdown brut, une colonne large décale tout
-- et la table devient illisible. Ce plugin la réaligne à l'affichage.
--
-- Prérequis déjà satisfaits par kickstart : parsers treesitter `markdown` et
-- `markdown_inline` (SECTION 9).
--
-- IMPORTANT : `vim.g.have_nerd_font` est à `false` dans init.lua, donc
-- `mini.icons` n'est pas initialisé et aucune glyphe Nerd Font n'est
-- disponible. Toutes les icônes réglées ci-dessous sont donc volontairement
-- choisies dans l'Unicode courant (ASCII, flèches, formes géométriques) : les
-- valeurs par défaut du plugin en sont pleines et s'afficheraient en carrés
-- vides. Si un jour le terminal passe à une Nerd Font, mettre
-- `vim.g.have_nerd_font = true` et supprimer les trois blocs `icons` d'ici.

vim.pack.add { 'https://github.com/MeanderingProgrammer/render-markdown.nvim' }

require('render-markdown').setup {
  -- Types de fichiers concernés. `markdown` suffit pour les fiches.
  file_types = { 'markdown' },

  -- Le rendu se désactive sur la ligne du curseur, pour éditer le texte réel.
  anti_conceal = {
    enabled = true,
    above = 0, -- aucune ligne masquée au-dessus du curseur
    below = 0, -- ni en dessous : une seule ligne brute à la fois
  },

  -- ------------------------------------------------------------------
  -- Le point qui motive tout le fichier
  -- ------------------------------------------------------------------
  pipe_table = {
    enabled = true,
    -- 'full' dessine aussi les bordures haute et basse, pas seulement le
    -- séparateur d'en-tête. C'est ce qui donne une vraie table encadrée.
    style = 'full',
    -- Bordures arrondies, en caractères de dessin de boîte — présents dans
    -- toutes les polices monospace courantes, pas besoin de Nerd Font.
    preset = 'round',
    -- 'padded' complète chaque cellule d'espaces virtuels pour aligner les
    -- colonnes. C'est LE réglage qui règle le problème des pipes en escalier.
    cell = 'padded',
    -- Espaces entre le contenu d'une cellule et sa bordure.
    padding = 1,
  },

  -- ------------------------------------------------------------------
  -- Le reste : lisible, et sans glyphe Nerd Font
  -- ------------------------------------------------------------------
  heading = {
    enabled = true,
    -- Pas de fond pleine largeur : sur des fiches très sectionnées
    -- (## En bref, ## Pièges, ## Voir aussi) ça saturerait l'écran.
    width = 'block',
    position = 'inline',
    -- Puces de niveau, style org-bullets. Les défauts sont des glyphes
    -- Nerd Font (󰲡 󰲣 …) et donneraient des carrés vides.
    icons = { '◉ ', '○ ', '✸ ', '✿ ', '◆ ', '◇ ' },
  },

  code = {
    enabled = true,
    -- 'block' encadre le bloc sur sa largeur réelle ; 'full' irait jusqu'au
    -- bord de la fenêtre, ce qui écraserait les blocs `sh` d'une ligne.
    width = 'block',
    right_pad = 2,
    -- Le nom du langage en en-tête : utile quand une fiche enchaîne sh, bat
    -- et text (cf. la règle « chaque ligne doit être collable » du memento).
    language_name = true,
    -- L'icône de langage passerait par mini.icons, qui n'est pas chargé.
    language_icon = false,
  },

  checkbox = {
    enabled = true,
    unchecked = { icon = '☐ ' },
    checked = { icon = '☑ ' },
  },

  -- Marque dans la gouttière en face de chaque titre : la glyphe par défaut
  -- (󰫎) est une Nerd Font, donc un carré vide ici — et elle n'apporte rien,
  -- le titre est déjà mis en évidence sur sa ligne.
  sign = { enabled = false },

  -- Les liens relatifs entre fiches sont nombreux et on veut pouvoir LIRE le
  -- chemin cible (c'est lui qu'on suit à la main, et que l'indexeur vérifie).
  -- Les icônes par défaut sont des glyphes Nerd Font : on les désactive.
  link = { enabled = false },

  -- Aucune formule LaTeX dans le memento : désactiver évite quatre
  -- avertissements de `:checkhealth` réclamant `latex2text` et `utftex`.
  latex = { enabled = false },
}

-- Bascule rapide pour revenir au markdown brut (copier une ligne de tableau,
-- vérifier un échappement, comparer à ce que Forgejo affichera).
vim.keymap.set('n', '<leader>tm', '<cmd>RenderMarkdown toggle<cr>', {
  desc = '[T]oggle rendu [M]arkdown',
})
