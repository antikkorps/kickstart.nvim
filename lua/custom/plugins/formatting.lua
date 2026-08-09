-- Formatage : prettier + format-on-save
--
-- NOTE: conform.nvim est déjà installé et configuré par `init.lua` (SECTION 7).
-- Ce fichier est chargé *après* init.lua (via `require 'custom.plugins'`), donc ce
-- second `setup` remplace le précédent. On garde ainsi init.lua intact, ce qui évite
-- les conflits lors des mises à jour de kickstart (voir NOTES_PERSO.md).

-- mason-lspconfig active automatiquement tout outil installé dans Mason qui possède une
-- config LSP dans nvim-lspconfig. C'est le cas de stylua, dont le serveur est lancé avec
-- `stylua --lsp` — un flag que stylua 2.1.0 ne connaît pas, d'où une erreur à chaque
-- fichier Lua ouvert. On le désactive : conform l'utilise déjà comme formateur.
vim.lsp.enable('stylua', false)

-- Filetypes formatés automatiquement à la sauvegarde
local format_on_save_filetypes = {
  javascript = true,
  typescript = true,
  javascriptreact = true,
  typescriptreact = true,
  json = true,
  jsonc = true,
  yaml = true,
  markdown = true,
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
