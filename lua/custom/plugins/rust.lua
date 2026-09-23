-- rustaceanvim : surcouche rust-analyzer
-- https://github.com/mrcjkb/rustaceanvim
--
-- Pourquoi un plugin plutôt que le serveur nu : rust-analyzer n'affiche dans le tampon
-- qu'une ligne tronquée pour une erreur d'emprunt, alors que le message complet de rustc
-- (les deux flèches « first borrow occurs here » / « second mutable borrow », puis le
-- `help:`) est justement la partie qui explique. `renderDiagnostic` va le chercher.
--
-- ATTENTION : rustaceanvim configure et attache rust-analyzer LUI-MÊME. `rust_analyzer`
-- doit donc rester absent de la table `servers` de lsp.lua, sinon deux clients
-- s'attachent au même tampon (diagnostics et actions de code en double).
-- `:checkhealth vim.lsp` liste qui est réellement attaché.
--
-- Le binaire reste celui de rustup (~/.cargo/bin/rust-analyzer), trouvé via le PATH :
-- c'est la version qui correspond à la toolchain active, là où le paquet Mason dérive
-- de la version de cargo.
--
-- NOTE: `vim.g.rustaceanvim` doit être défini AVANT que le plugin ne soit sourcé, donc
-- avant l'appel à `vim.pack.add` — même contrainte que pour vim-matchup.

vim.g.rustaceanvim = {
  server = {
    on_attach = function(_, bufnr)
      local map = function(keys, action, desc)
        vim.keymap.set('n', keys, function() vim.cmd.RustLsp(action) end, { buffer = bufnr, desc = 'Rust: ' .. desc })
      end

      -- Le message rustc complet, celui qui explique vraiment l'erreur.
      map('<leader>rd', 'renderDiagnostic', 'rendu du [d]iagnostic')
      -- L'équivalent de `rustc --explain E0382`, avec son exemple avant/après.
      map('<leader>re', 'explainError', '[e]xpliquer l\'erreur')
      -- Lance le test sous le curseur : la boucle « test rouge -> vert » sans quitter nvim.
      map('<leader>rr', 'runnables', '[r]unnables (test sous le curseur)')
    end,
  },
}

vim.pack.add { 'https://github.com/mrcjkb/rustaceanvim' }
