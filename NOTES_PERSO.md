# Notes de maintenance pour ma configuration Neovim (Kickstart)

Ce document résume la procédure pour mettre à jour ma configuration Neovim en récupérant
les dernières modifications du dépôt officiel de Kickstart, tout en préservant mes
personnalisations.

## Contexte

- La config vit dans `~/.config/nvim-kickstart` et se lance avec l'alias `nk`
  (`NVIM_APPNAME="nvim-kickstart" nvim`).
- Neovim est installé en AppImage dans `/usr/local/bin/nvim` (remplacer le fichier pour
  mettre à jour). Une copie de la 0.11.4 est gardée dans `~/.local/bin/`.
- **Depuis août 2026, kickstart utilise `vim.pack`** (le gestionnaire de plugins intégré à
  Neovim) à la place de `lazy.nvim`. Cela impose **Neovim >= 0.12**.

## Structure des branches

- **`master`** : miroir exact de `upstream/master` (dépôt officiel de Kickstart).
  **Ne jamais y commiter de modifications personnelles.**
- **`custom`** : branche où vivent toutes les personnalisations. **C'est la branche de
  travail** — c'est elle qui est déployée, jamais `master`.
- **`custom-pre-0.12`** : archive de l'ancienne config lazy.nvim (avant migration `vim.pack`).

`custom` est **`master` + mes personnalisations**, et se met à jour en **fusionnant**
`master` dedans (voir la procédure plus bas). Elle n'est jamais rebasée : son historique
est publié sur `origin`, et un rebase obligerait à un force-push pour retomber sur le même
arbre.

Les deux étiquettes bougent indépendamment. Si `git branch -vv` annonce
`master [origin/master: behind N]`, ça ne veut **pas** dire que la config est en retard :
le plus souvent `custom` a déjà fusionné ces commits et seule l'étiquette `master` locale
a pris du retard. La vérification qui tranche :

```bash
git merge-base --is-ancestor master custom && echo "custom est a jour"
```

## Mes personnalisations

Tout est confiné dans `lua/custom/plugins/` (chargé automatiquement par
`lua/custom/plugins/init.lua`, qui `require` chaque fichier `.lua` du dossier) :

| Fichier | Rôle |
| :------ | :--- |
| `smear_cursor.lua` | traînée animée du curseur |
| `rainbow.lua` | rainbow-delimiters (parenthèses/balises colorées) |
| `matchup.lua` | vim-matchup (navigation `%` étendue) |
| `formatting.lua` | prettier + format-on-save (surcouche du conform.nvim d'init.lua) |
| `autotag.lua` | fermeture/renommage auto des balises HTML, JSX, Vue |
| `autopairs.lua` | active `check_ts` sur le nvim-autopairs de kickstart |
| `pack.lua` | commandes `:Pack` / `:PackUpdate` / `:PackClean` (confort autour de `vim.pack`) |
| `markdown.lua` | render-markdown.nvim : rendu du markdown dans le tampon (tableaux alignés) |
| `lsp.lua` | serveurs LSP de mes langages (init.lua ne declare que lua_ls) |

### Raccourcis ajoutés par mes plugins

| Raccourci | Mode | Action | Défini dans |
| :-------- | :--- | :----- | :---------- |
| `<leader>tm` | n | bascule le rendu markdown (`:RenderMarkdown toggle`) | `markdown.lua` |
| `<leader>pp` | n | état des plugins, sans réseau (`:Pack`) | `pack.lua` |
| `<leader>pu` | n | chercher les mises à jour (`:PackUpdate`) | `pack.lua` |
| `<leader>pc` | n | supprimer les plugins retirés (`:PackClean`) | `pack.lua` |

Ce sont les seuls raccourcis que j'ajoute ; tout le reste vient de kickstart. Pour
retrouver la liste à jour sans ouvrir ce fichier : `:nmap <leader>`.

`<leader>t` est le groupe `[T]oggle` déjà déclaré par la `spec` de which-key dans
`init.lua` (SECTION 4) : un raccourci de bascule ajouté ici y apparaît tout seul, il suffit
de lui donner un `desc`. Taper `<leader>t` et attendre liste le groupe. `<leader>p` n'est
déclaré nulle part comme groupe — which-key affiche quand même les trois raccourcis, mais
sans titre ; ajouter `{ '<leader>p', group = '[P]ack' }` à la `spec` si ça gêne.

Les seuls changements dans les fichiers de kickstart lui-même :

- `init.lua` : décommenter `require 'custom.plugins'` et
  `require 'kickstart.plugins.autopairs'` (SECTION 10).
- `.gitignore` : commenter `nvim-pack-lock.json` pour suivre le lockfile en version control.

> Garder ces deux modifications aussi minimales que possible : ce sont les seuls points de
> conflit possibles lors d'une fusion de `master`. Les fichiers de
> `lua/custom/plugins/` n'entrent jamais en conflit — kickstart n'y touche pas.

## Rendu markdown : le désactiver pour copier

`markdown.lua` active render-markdown.nvim sur tous les fichiers `.md` — c'est ce qui
redessine les tableaux du memento avec des bordures et des colonnes alignées.

**Bascule :** `<leader>tm`, ou `:RenderMarkdown toggle`. Autres commandes utiles :
`:RenderMarkdown disable` / `enable`, et `:RenderMarkdown buf_toggle` pour n'agir que sur
le tampon courant.

### Ce qui n'est PAS affecté : le yank

Le rendu est fait d'`extmarks` et de texte virtuel — **le contenu du tampon n'est jamais
modifié**. Un `yy` sur une ligne de tableau rend le markdown brut, y compris ce que le
`conceallevel=3` masque à l'écran :

```text
affiché : │ Should have │ important, mais il existe un contournement │ douloureux │
yanké   : | **S**hould have | important, mais il existe un contournement acceptable | … |
```

Donc pour copier **une ligne**, rien à désactiver. C'est le flux du memento
(`m find` → éditeur → `yy` → coller) et il fonctionne tel quel.

### Ce qui l'est : tout ce qui compte des lignes

Le piège réel est ailleurs. Une cellule trop large est repliée sur plusieurs **lignes
virtuelles**, qui n'existent pas dans le fichier. Un tableau de 4 lignes réelles peut en
occuper 12 à l'écran, et les numéros de ligne sautent dans la gouttière.

Conséquence : `V`, `yap`, `4yy`, `dd` et les comptes de lignes portent sur le **fichier**,
pas sur ce qu'on voit. Sélectionner un tableau entier à l'œil donne systématiquement le
mauvais nombre de lignes.

**Réflexe : `<leader>tm` avant de sélectionner un bloc de tableau, puis `<leader>tm` à
nouveau.** Utile aussi pour vérifier un échappement ou comparer à ce que Forgejo affichera.

### Icônes

`vim.g.have_nerd_font` est à `false` dans `init.lua`, donc `mini.icons` n'est pas
initialisé. Les icônes par défaut de render-markdown sont des glyphes Nerd Font et
s'afficheraient en carrés vides : `markdown.lua` les remplace toutes par de l'Unicode
courant (`◉ ○ ✸`, `☐ ☑`), et désactive `sign`, `link` et `code.language_icon`.

Si le terminal passe un jour à une Nerd Font, mettre `vim.g.have_nerd_font = true` et
supprimer ces blocs — l'en-tête de `markdown.lua` le rappelle.

## Serveurs LSP

`init.lua` (SECTION 8) ne declare que `lua_ls`. `lua/custom/plugins/lsp.lua` ajoute les
autres apres coup, sans toucher a l'amont — meme principe que `formatting.lua`.

| Serveur | Langage | Paquet Mason |
| :------ | :------ | :----------- |
| `ts_ls` | JavaScript / TypeScript | typescript-language-server |
| `intelephense` | PHP, WordPress | intelephense |
| `rust_analyzer` | Rust | **aucun** — `rustup component add rust-analyzer` |
| `bashls` | shell | bash-language-server + shellcheck |
| `html` / `cssls` / `jsonls` | web | html-lsp, css-lsp, json-lsp |
| `marksman` | markdown | marksman |

Deux choix a connaitre :

- **`rust_analyzer` ne vient pas de Mason.** `rustup component add rust-analyzer` fournit
  la version qui correspond exactement a la toolchain active ; le binaire Mason, lui,
  derive de sa propre version. Il est trouve via `~/.cargo/bin` dans le PATH.
- **`intelephense` recoit une liste de `stubs` incluant `wordpress`.** Sans elle, chaque
  `add_action`, `WP_Query`, `wp_enqueue_script` est signale comme fonction inconnue.

Ce que ca apporte : complétion (blink.cmp, deja installe par kickstart), diagnostics a la
frappe, `grd` aller a la definition, `grn` renommer, `gra` actions de code. `marksman` est
la pour le memento : il complete les liens relatifs entre fiches et signale un lien mort au
moment ou on l'ecrit, au lieu d'attendre `m check`.

### Delais d'attache mesures

```
ts_ls          0.1 s      jsonls     0.1 s      marksman        0.9 s
intelephense   0.3 s      html       0.3 s      rust_analyzer   0.0 s
cssls          0.2 s      bashls    21.0 s      <- anomalie
```

**`bashls` met ~20 s**, de facon reproductible, a froid comme a chaud. Ecartes par la
mesure : le demarrage de node (70 ms), l'absence de shellcheck, l'analyse de fond
(`backgroundAnalysisMaxFiles = 0` n'y change rien), le shell (`SHELL=bash` ou `sh` :
identique) et la version de node (24 comme 26) — cause non identifiee. L'attache etant
asynchrone, l'editeur reste utilisable et la completion arrive en retard. Pour s'en
debarrasser : commenter `bashls` dans `lsp.lua`, treesitter continue de colorer.

### Ajouter un serveur

Chercher son nom dans `:help lspconfig-all`, l'ajouter a la table `servers` de `lsp.lua`,
relancer nvim (mason-tool-installer installe le paquet). `:checkhealth vim.lsp` dit qui
tourne reellement sur le tampon courant.

> `lsp.lua` rappelle `mason-tool-installer.setup`, ce qui **remplace** la configuration
> posee par `init.lua`. Sa liste `ensure_installed` doit donc rester complete — d'ou
> `lua_ls` qui y figure alors qu'il vient de l'amont.

## Formatage

`formatting.lua` surcharge le conform.nvim d'`init.lua` : prettier sur JS/TS, JSON, YAML,
HTML, CSS, et stylua sur Lua, avec format-on-save.

**Le markdown est volontairement exclu du format-on-save.** Prettier ne se contente pas de
mettre en forme : il convertit tout l'italique `*terme*` en `_terme_` et bourre les
cellules des tableaux d'espaces. Sur une fiche du memento, un simple `:w` produisait
**52 lignes modifiees**, et `m check` restait vert — rien ne prevenait. Le memento a ses
propres conventions (`CONVENTIONS.md` prescrit `(*wildcard*)` en asterisques).

Le formateur reste declare : `<leader>f` formate un markdown a la demande.

## Format des fichiers de plugin (`vim.pack`)

Avec `vim.pack`, un fichier de `custom/plugins/` **n'est plus une spec retournée** comme avec
lazy.nvim : c'est du code exécuté directement.

```lua
-- Les variables g: attendues par un plugin vimscript se règlent AVANT le vim.pack.add
vim.g.mon_option = 1

vim.pack.add { 'https://github.com/auteur/le-plugin.nvim' }
require('le_plugin').setup {}
```

Pour épingler une version : `vim.pack.add { { src = '...', version = vim.version.range '1.*' } }`.

## Procédure de mise à jour de kickstart

### 0. Vérifier qu'il y a bien quelque chose à faire

```bash
git fetch upstream
git merge-base --is-ancestor upstream/master custom && echo "deja a jour, rien a faire"
```

À faire **avant** de regarder `git branch -vv` : un `master [behind N]` ne prouve rien,
c'est souvent juste l'étiquette locale qui traîne (voir « Structure des branches »).

### 1. Mettre à jour la branche `master` locale

```bash
git checkout master
git merge --ff-only upstream/master   # doit toujours passer : master ne porte aucun commit perso
git push origin master
```

`--ff-only` plutôt que `git pull` : si la fusion n'est pas en avance rapide, c'est qu'un
commit personnel a atterri sur `master` par erreur. Mieux vaut que git refuse.

### 2. Fusionner `master` dans `custom`

```bash
git checkout custom
git merge master
```

**Fusionner, pas rebaser.** `custom` est publiée sur `origin` : un `git rebase master`
rejoue les ~10 commits personnels un par un, demande de résoudre le même conflit `init.lua`
à chaque passage, impose un force-push, et retombe sur exactement le même arbre. Aucun gain.

En cas de conflit — seulement `init.lua` et `.gitignore`, jamais `lua/custom/plugins/` :
résoudre, `git add .`, puis `git commit`.

Puis vérifier que la config charge encore avant de pousser :

```bash
NVIM_APPNAME=nvim-kickstart nvim --headless -c 'qa!'   # doit sortir sans erreur
git push origin custom
```

Dans nvim, compléter par `:checkhealth` sur les plugins touchés.

Si la mise à jour upstream est massive (réécriture d'`init.lua`), il est plus rapide de
repartir propre :

```bash
git branch custom-pre-<date> custom   # archive
git checkout custom && git reset --hard master
# recréer les 8 fichiers de lua/custom/plugins/ + les 2 lignes d'init.lua/.gitignore
```

### 3. Mettre à jour les plugins

Plus de `:Lazy`. Les commandes définies dans `lua/custom/plugins/pack.lua` :

| Commande | Raccourci | Rôle |
| :------- | :-------- | :--- |
| `:Pack` | `<leader>pp` | état des plugins, sans réseau |
| `:PackUpdate` | `<leader>pu` | chercher les mises à jour |
| `:PackClean` | `<leader>pc` | supprimer les plugins retirés de la config |

Dans le buffer qui s'ouvre : **`:write` applique** les mises à jour, **`:quit` annule**.
Penser ensuite à commiter `nvim-pack-lock.json`.

`vim.pack` ne supprime jamais de lui-même un plugin retiré de la config : il reste sur le
disque tant qu'on ne lance pas `:PackClean`.

Les commandes brutes en dessous, si besoin : `:lua vim.pack.update(nil, { offline = true })`
et `:lua vim.pack.update()`.

### 4. Forcer la mise à jour du fork distant

À n'utiliser que si `upstream` a réécrit son historique, ou après un
`reset --hard` de l'étape 2. En fonctionnement normal, `git push origin master` de
l'étape 1 suffit, et **`custom` ne se force-pushe jamais** — c'est tout l'intérêt de
fusionner plutôt que de rebaser.

```bash
git checkout master
git push origin master --force
```

## Dépendances externes requises

`git`, `make`, `unzip`, `gcc`, `ripgrep`, `fd`, **`tree-sitter` (CLI)**.
Le CLI `tree-sitter` est devenu obligatoire : nvim-treesitter est passé sur sa branche `main`
et compile les parsers avec.

Une **Nerd Font est facultative** : `vim.g.have_nerd_font` est à `false`, kickstart dégrade
proprement et mes plugins sont réglés pour s'en passer (voir « Rendu markdown » ci-dessus).
La passer à `true` suppose d'avoir aussi changé la police du terminal.
