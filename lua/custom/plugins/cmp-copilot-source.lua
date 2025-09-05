return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    opts.sources = opts.sources or {}
    -- on met copilot en tête des sources
    table.insert(opts.sources, 1, { name = "copilot" })
    return opts
  end,
}

