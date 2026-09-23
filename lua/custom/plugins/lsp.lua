-- Serveurs LSP pour mes langages
--
-- NOTE: `init.lua` (SECTION 8) ne déclare que `lua_ls`. Ce fichier est chargé *après*
-- (via `require 'custom.plugins'`), donc il ajoute les autres sans toucher à l'amont —
-- même principe que `formatting.lua`. Voir NOTES_PERSO.md.
--
-- Ce que ça apporte, concrètement : complétion (via blink.cmp, déjà installé par
-- kickstart), diagnostics à la frappe, `grd` aller à la définition, `grn` renommer,
-- `gra` actions de code. Sans serveur, on n'a que la coloration treesitter.
--
-- Pour en ajouter un : chercher son nom dans `:help lspconfig-all`, l'ajouter à `servers`
-- ci-dessous, puis `:MasonInstall <paquet>` (ou relancer nvim, mason-tool-installer s'en
-- charge). `:checkhealth vim.lsp` dit qui tourne réellement sur le tampon courant.

---@type table<string, vim.lsp.Config>
local servers = {
  -- JavaScript / TypeScript. Paquet Mason : typescript-language-server.
  ts_ls = {},

  -- PHP et WordPress. Paquet Mason : intelephense.
  -- La version gratuite suffit largement (pas de licence à fournir) ; elle couvre
  -- complétion, diagnostics et navigation. `stubs` déclare les extensions PHP connues :
  -- sans `wordpress`, tous les appels à `add_action`, `wp_query`… sont signalés comme
  -- fonctions inconnues.
  intelephense = {
    settings = {
      intelephense = {
        stubs = {
          'apache', 'bcmath', 'bz2', 'calendar', 'com_dotnet', 'Core', 'ctype', 'curl',
          'date', 'dba', 'dom', 'enchant', 'exif', 'fileinfo', 'filter', 'fpm', 'ftp',
          'gd', 'hash', 'iconv', 'imap', 'intl', 'json', 'ldap', 'libxml', 'mbstring',
          'mcrypt', 'mysqli', 'oci8', 'odbc', 'openssl', 'pcntl', 'pcre', 'PDO',
          'pdo_mysql', 'pdo_pgsql', 'pdo_sqlite', 'pgsql', 'Phar', 'posix', 'pspell',
          'readline', 'Reflection', 'session', 'shmop', 'SimpleXML', 'soap', 'sockets',
          'sodium', 'SPL', 'sqlite3', 'standard', 'superglobals', 'sysvmsg', 'sysvsem',
          'sysvshm', 'tidy', 'tokenizer', 'xml', 'xmlreader', 'xmlrpc', 'xmlwriter',
          'xsl', 'zip', 'zlib', 'wordpress', 'woocommerce', 'acf-pro',
        },
      },
    },
  },

  -- Rust : PAS ici. rustaceanvim (voir rust.lua) configure et attache rust-analyzer
  -- lui-même ; l'ajouter à cette table attacherait un second client au même tampon
  -- (diagnostics et actions de code en double).

  -- Shell. Paquet Mason : bash-language-server, complété par shellcheck pour les
  -- diagnostics.
  --
  -- ATTENTION : mesuré ici, il met **~20 s** à s'attacher, de façon reproductible (à
  -- froid comme à chaud). Écartés par la mesure : le démarrage de node (70 ms), l'absence
  -- de shellcheck, l'analyse de fond (`backgroundAnalysisMaxFiles = 0` n'y change rien),
  -- le shell (`SHELL=bash` ou `sh` : identique) et la version de node (24 comme 26) —
  -- cause non identifiée. L'attache est asynchrone : l'éditeur reste utilisable, la
  -- complétion arrive juste en retard. Si ça devient gênant, commenter cette ligne ;
  -- treesitter continue de colorer les scripts.
  bashls = {},

  -- HTML, CSS, JSON — les trois viennent du même paquet Mason :
  -- vscode-langservers-extracted.
  html = {},
  cssls = {},
  jsonls = {},

  -- Markdown. Paquet Mason : marksman.
  -- Choisi pour le memento : il complète les liens relatifs entre fiches, permet de
  -- sauter à la fiche cible avec `grd`, et signale un lien mort — la même vérification
  -- que `scripts/index.js`, mais au moment où on écrit plutôt qu'au `m check`.
  marksman = {},
}

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end

-- Installation automatique. `init.lua` appelle déjà `mason-tool-installer.setup` avec la
-- seule clé `lua_ls` ; ce second appel remplace sa configuration, donc la liste doit être
-- complète — d'où `lua_ls` répété ici.
local ensure_installed = { 'lua_ls' }
for name in pairs(servers) do
  table.insert(ensure_installed, name)
end

-- Formateurs et linters, que Mason doit aussi fournir. `shellcheck` est utilisé par
-- bash-language-server pour ses diagnostics.
vim.list_extend(ensure_installed, { 'stylua', 'prettierd', 'prettier', 'shellcheck' })

require('mason-tool-installer').setup { ensure_installed = ensure_installed }
