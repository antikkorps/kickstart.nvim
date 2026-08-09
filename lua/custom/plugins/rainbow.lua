-- rainbow-delimiters.nvim : coloration des délimiteurs imbriqués
-- https://github.com/HiPhish/rainbow-delimiters.nvim

vim.pack.add { 'https://github.com/HiPhish/rainbow-delimiters.nvim' }

local rd = require 'rainbow-delimiters'

vim.g.rainbow_delimiters = {
  strategy = {
    [''] = rd.strategy.global, -- défaut
    commonlisp = rd.strategy['local'],
  },
  query = {
    [''] = 'rainbow-parens', -- défaut
    html = 'rainbow-tags',
    xml = 'rainbow-tags',
    vue = 'rainbow-tags',
    svelte = 'rainbow-tags',
    latex = 'rainbow-blocks',
    bibtex = 'rainbow-blocks',
  },
  -- NOTE: pas de table `highlight` ici : on garde les groupes par défaut du plugin
  -- (RainbowDelimiterRed, RainbowDelimiterYellow, ...), qui suivent le thème.
}
