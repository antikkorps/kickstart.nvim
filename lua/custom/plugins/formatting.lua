-- kickstart/plugins/formatting.lua

return {
  -- Conform.nvim pour le formatage
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" }, -- Se charge avant l'écriture du buffer
    cmd = { "ConformInfo" },
    opts = {
      -- Configuration pour activer le formatage à la sauvegarde
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true, -- Tombe sur le formateur LSP si conform échoue
      },

      -- Définition des formateurs par type de fichier (Filetype)
      formatters_by_ft = {
        lua = { "stylua" },

        -- Configuration pour Prettier (ajoutez les langages que vous utilisez)
        javascript = { "prettierd", "prettier" },
        typescript = { "prettierd", "prettier" },
        javascriptreact = { "prettierd", "prettier" },
        typescriptreact = { "prettierd", "prettier" },
        json = { "prettierd", "prettier" },
        yaml = { "prettierd", "prettier" },
        markdown = { "prettierd", "prettier" },
        html = { "prettierd", "prettier" },
        css = { "prettierd", "prettier" },
        scss = { "prettierd", "prettier" },

        -- Vous pouvez ajouter d'autres formateurs ici
        -- python = { "isort", "black" },
      },
    },
  },
}
