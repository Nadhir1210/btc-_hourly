# BTC Hourly — Analysis (R / Python / Quarto)

Projet d’analyse de données **BTC hourly OHLCV + indicateurs** avec :
- un pipeline **R** (scripts + outputs),
- un notebook **Python**,
- des rapports **Quarto** (Python et R).

## Données

- Fichier principal : `data/btc_hourly_ohclv_ta.csv`
- Colonne temps : `DATETIME`
- Variable étudiée : `Q = CLOSE`

## Exécuter l’analyse en R (pipeline)

Pré-requis : R installé (ex: R 4.5+) + `renv` déjà initialisé dans ce repo.

1) Restaurer l’environnement R (si besoin)

```r
renv::restore()
```

2) Lancer toutes les tâches R (Task 1 + Task 2) et générer les fichiers dans `outputs/`

```bash
"C:\Program Files\R\R-4.5.2\bin\Rscript.exe" run_all.R
```

> Si ton Rscript est ailleurs, adapte le chemin.

## Notebook Python (Task 1 + Task 2)

- Notebook : `btc_analysis.ipynb`
- Il lit `data/btc_hourly_ohclv_ta.csv` et affiche les tables/plots dans le notebook.

Dépendances Python typiques : `numpy`, `pandas`, `matplotlib`, `seaborn`, `scipy`.

## Rapports Quarto

### 1) Rapport Quarto Python (exécute le code)

- Source : `btc_python_report.qmd`

Exécution (PowerShell) :

```powershell
cd "C:\Users\Nadhir\Desktop\btc _hourly"
$env:QUARTO_PYTHON="C:\Users\Nadhir\Desktop\btc _hourly\.venv\Scripts\python.exe"
quarto preview btc_python_report.qmd
```

Ou rendu simple :

```powershell
$env:QUARTO_PYTHON="C:\Users\Nadhir\Desktop\btc _hourly\.venv\Scripts\python.exe"
quarto render btc_python_report.qmd
```

### 2) Rapport Quarto R (exécute le code)

- Source : `btc_r_report.qmd`

```powershell
cd "C:\Users\Nadhir\Desktop\btc _hourly"
quarto preview btc_r_report.qmd
```

### 3) Rapport Quarto basé sur les outputs (sans recalcul)

- Source : `elbe_report.qmd`
- HTML : `elbe_report.html`

Ce rapport lit les fichiers déjà générés dans `outputs/`.

## Notes

- Certains fichiers HTML peuvent être ignorés par `.gitignore`.
- Sur Windows, Git peut afficher un warning `LF` → `CRLF` sur les notebooks : c’est normal.
