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
| `autopairs.lua` | active `check_ts` sur le nvim-autopairs de kickstart |
| `pack.lua` | commandes `:Pack` / `:PackUpdate` / `:PackClean` (confort autour de `vim.pack`) |
| `markdown.lua` | render-markdown.nvim : rendu du markdown dans le tampon (tableaux alignés) |

Les seuls changements dans les fichiers de kickstart lui-même :

- `init.lua` : décommenter `require 'custom.plugins'` et
  `require 'kickstart.plugins.autopairs'` (SECTION 10).
- `.gitignore` : commenter `nvim-pack-lock.json` pour suivre le lockfile en version control.

> Garder ces deux modifications aussi minimales que possible : ce sont les seuls points de
> conflit possibles lors d'un rebase.

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
supprimer ces blocs — l'en-tête de `markdown.lua` le rappelle. (La section
« Dépendances externes » ci-dessous mentionne une Nerd Font comme requise : en pratique la
config tourne sans, kickstart dégradant proprement.)

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
