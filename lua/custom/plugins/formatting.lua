-- Formatage : prettier + format-on-save
--
-- NOTE: conform.nvim est déjà installé et configuré par `init.lua` (SECTION 7).
-- Ce fichier est chargé *après* init.lua (via `require 'custom.plugins'`), donc ce
-- second `setup` remplace le précédent. On garde ainsi init.lua intact, ce qui évite
-- les conflits lors des mises à jour de kickstart (voir NOTES_PERSO.md).

-- mason-lspconfig active automatiquement tout outil installé dans Mason qui possède une
-- config LSP dans nvim-lspconfig, y compris de simples formateurs. On les rend à leur rôle
-- de formateur/linter (lancés par conform ou nvim-lint) en coupant leur serveur.
--
--   stylua : démarré avec `stylua --lsp`, flag inconnu de stylua 2.1.0 -> erreur à chaque
--            fichier Lua ouvert.
--   sqruff : idem pour le SQL, inutile ici.
--
-- Pour en couper un autre, ajouter son nom à la liste (voir `:checkhealth vim.lsp` pour
-- savoir qui tourne).
for _, server in ipairs { 'stylua', 'sqruff' } do
  vim.lsp.enable(server, false)
end

-- Filetypes formatés automatiquement à la sauvegarde
--
-- PAS de `markdown` ici, délibérément. Prettier réécrit le markdown au-delà de la mise en
-- forme : il convertit tout l'italique `*terme*` en `_terme_` et bourre les cellules des
-- tableaux d'espaces. Sur une fiche du memento, un simple `:w` produisait 52 lignes
-- modifiées — et `m check` restait vert, donc rien ne prévenait. Le memento a ses propres
-- conventions (CONVENTIONS.md prescrit l'italique en astérisques, `(*wildcard*)`) et
-- prettier les contredit en silence.
--
-- Le formateur reste déclaré dans `formatters_by_ft` plus bas : `<leader>f` formate un
-- markdown à la demande, quand c'est vraiment ce qu'on veut.
local format_on_save_filetypes = {
  javascript = true,
  typescript = true,
  javascriptreact = true,
  typescriptreact = true,
  json = true,
  jsonc = true,
  yaml = true,
  html = true,
  css = true,
  scss = true,
  lua = true,
}

local prettier = { 'prettierd', 'prettier', stop_after_first = true }

require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    if format_on_save_filetypes[vim.bo[bufnr].filetype] then return { timeout_ms = 500 } end
    return nil
  end,
  default_format_opts = {
    -- Utilise les formateurs externes ci-dessous, et retombe sur le LSP sinon
    lsp_format = 'fallback',
  },
  formatters_by_ft = {
    lua = { 'stylua' },
    javascript = prettier,
    typescript = prettier,
    javascriptreact = prettier,
    typescriptreact = prettier,
    json = prettier,
    jsonc = prettier,
    yaml = prettier,
    markdown = prettier,
    html = prettier,
    css = prettier,
    scss = prettier,
  },
}
