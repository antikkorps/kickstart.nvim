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
- **`custom`** : branche où vivent toutes les personnalisations.
- **`custom-pre-0.12`** : archive de l'ancienne config lazy.nvim (avant migration `vim.pack`).

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
| `pack.lua` | commandes `:Pack` / `:PackUpdate` / `:PackClean` (confort autour de `vim.pack`) |

Le seul changement dans les fichiers de kickstart lui-même :

- `init.lua` : décommenter `require 'custom.plugins'` (SECTION 10).
- `.gitignore` : commenter `nvim-pack-lock.json` pour suivre le lockfile en version control.

> Garder ces deux modifications aussi minimales que possible : ce sont les seuls points de
> conflit possibles lors d'un rebase.

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

### 1. Mettre à jour la branche `master` locale

```bash
git checkout master
git pull upstream master
```

### 2. Rejouer les personnalisations par-dessus

```bash
git checkout custom
git rebase master
```

En cas de conflit : résoudre, `git add .`, puis `git rebase --continue`.

Si la mise à jour upstream est massive (réécriture d'`init.lua`), il est plus rapide de
repartir propre :

```bash
git branch custom-pre-<date> custom   # archive
git checkout custom && git reset --hard master
# recréer les 4 fichiers de lua/custom/plugins/ + les 2 lignes d'init.lua/.gitignore
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

### 4. Forcer la mise à jour du fork distant (si `master` a été réinitialisée)

```bash
git checkout master
git push origin master --force
```

## Dépendances externes requises

`git`, `make`, `unzip`, `gcc`, `ripgrep`, `fd`, **`tree-sitter` (CLI)**, un Nerd Font.
Le CLI `tree-sitter` est devenu obligatoire : nvim-treesitter est passé sur sa branche `main`
et compile les parsers avec.
