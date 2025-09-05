-- Accepte la complétion (cmp ou Copilot ghost) puis quitte l'insert
return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    local cmp = require("cmp")
    local function leave_insert()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
    end

    opts.mapping = vim.tbl_extend("force", opts.mapping or {}, {
      ["<C-;>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.confirm({ select = true })
          return leave_insert()
        end
        local ok, s = pcall(require, "copilot.suggestion")
        if ok and s.is_visible() then
          s.accept()
          return leave_insert()
        end
        fallback()
      end, { "i", "s" }),
    })
    return opts
  end,
}
