return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local rd = require("rainbow-delimiters")
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rd.strategy.global,      -- défaut
          commonlisp = rd.strategy["local"],
        },
        query = {
          [""] = "rainbow-parens",        -- par défaut
          html = "rainbow-tags",
          xml = "rainbow-tags",
          vue = "rainbow-tags",
          svelte = "rainbow-tags",
          latex = "rainbow-blocks",
          bibtex = "rainbow-blocks",
        },
        -- Palette (facultatif, sinon thème par défaut)
        highlight = {
          "TSRainbowRed",
          "TSRainbowYellow",
          "TSRainbowBlue",
          "TSRainbowOrange",
          "TSRainbowGreen",
          "TSRainbowViolet",
          "TSRainbowCyan",
        },
      }
    end,
  },
}

