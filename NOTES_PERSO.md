# Notes de maintenance pour ma configuration Neovim (Kickstart)

Ce document résume la procédure pour mettre à jour ma configuration Neovim en récupérant les dernières modifications du dépôt officiel de Kickstart, tout en préservant mes personnalisations.

## Structure des branches

- **`master`** : Branche locale qui doit rester un miroir exact de `upstream/master` (le dépôt officiel de Kickstart). **Ne jamais commiter de modifications personnelles sur cette branche.**
- **`custom`** : Branche où toutes les modifications personnelles (ajouts de plugins, modifications de configuration dans le dossier `custom/`) sont effectuées.

## Procédure de mise à jour

Suivre ces étapes pour synchroniser les mises à jour de Kickstart avec la configuration personnelle.

### 1. Mettre à jour la branche `master` locale

Récupérer les derniers changements depuis le dépôt officiel de Kickstart (`upstream`).

```bash
# Basculer sur la branche master locale
git checkout master

# Récupérer les modifications de l'upstream (Kickstart original)
git pull upstream master
```

### 2. Appliquer les mises à jour à la branche personnelle via Rebase

Appliquer les nouveaux commits de `master` sous les commits de la branche personnelle.

```bash
# Basculer sur la branche de configuration personnelle
git checkout custom

# Rejouer les modifications personnelles par-dessus la master mise à jour
git rebase master
```

### 3. Gestion des conflits (si nécessaire)

Si le _rebase_ est interrompu par des conflits de fusion (parce que Kickstart a modifié un fichier que vous avez aussi modifié) :

1.  Ouvrir les fichiers indiqués comme ayant des conflits dans Neovim.
2.  Résoudre manuellement les conflits (garder votre version, celle de Kickstart, ou un mélange des deux).
3.  Sauvegarder les fichiers résolus.
4.  Continuer le rebase :
    ```bash
    git add .
    git rebase --continue
    ```

### 4. Forcer la mise à jour du fork distant (si `master` a été réinitialisée)

Si la branche `master` locale a été réinitialisée (`git reset --hard upstream/master`), il faut forcer la mise à jour du fork sur GitHub :

```bash
git checkout master
git push origin master --force
```
