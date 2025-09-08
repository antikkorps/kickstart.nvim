return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter', -- Se charge dès que vous entrez en mode insertion
  config = function()
    require('nvim-autopairs').setup {
      check_ts = true, -- Utiliser Treesitter pour vérifier les paires
    }
  end,
}
