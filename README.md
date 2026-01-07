# Projet R (Windows) — environnement reproductible avec renv

Ce dossier contient `btc_hourly_ohclv_ta.csv` et une config d’environnement R reproductible via **renv**.

## Prérequis (Windows)

1) Installer R (64-bit) : https://cran.r-project.org/bin/windows/base/

2) (Optionnel mais conseillé) Installer Rtools si tu compiles des packages : https://cran.r-project.org/bin/windows/Rtools/

3) Vérifier que `Rscript` est accessible (nouveau terminal) :

```powershell
where Rscript
Rscript --version
```

## Initialiser / restaurer l’environnement

Depuis ce dossier :

```powershell
Set-Location -LiteralPath "D:\projet   R"
Rscript .\setup.R
```

- Si c’est la première fois, `setup.R` va installer `renv`, initialiser le projet, puis installer les packages.
- Ensuite tu peux (re)lancer `setup.R` quand tu veux pour restaurer/synchroniser.

## Lancer un exemple d’analyse

```powershell
Set-Location -LiteralPath "D:\projet   R"
Rscript .\analysis.R
```

L’exemple lit le CSV, affiche un résumé et calcule quelques stats simples.

## Notes

- Le fichier `renv.lock` (généré après init) fige les versions de packages.
- Le dossier `renv/` est un dossier de config du projet (à versionner), et la bibliothèque locale se met dans `renv/library/` (souvent ignorée en git).

## Publication sur GitHub Pages

Le projet est configuré pour publier automatiquement sur GitHub Pages via GitHub Actions.

### Publication automatique

À chaque `git push` sur la branche `main`, les documents Quarto sont automatiquement rendus et publiés.

**URL du site** : https://nadhir1210.github.io/btc-_hourly/

### Publication manuelle (depuis local)

```powershell
quarto publish gh-pages
```

### Activer GitHub Pages (première fois)

1. Va sur https://github.com/Nadhir1210/btc-_hourly/settings/pages
2. Sous "Build and deployment", sélectionne **Source: GitHub Actions**
3. Pousse tes changements et le workflow se lancera automatiquement
