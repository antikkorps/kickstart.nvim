-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
{
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  opts = {
    suggestion = { enabled = true, auto_trigger = true },
    panel = { enabled = true },
  },
},
{
  "andymass/vim-matchup",
  config = function()
    vim.g.matchup_matchparen_offscreen = { method = "popup" }
  end,
},
}
