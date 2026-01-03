# -------------------------------
# 0️⃣ Préparation et packages
# -------------------------------
suppressPackageStartupMessages({
  library(tidyverse)   # tidy data & ggplot
  library(lubridate)   # manipulation de dates
})

# Helpers (fonctions personnalisées)
source("R/elbe_helpers.R")

# -------------------------------
# 1️⃣ Arguments et chemins
# -------------------------------
args <- commandArgs(trailingOnly = TRUE)

# Fonction utilitaire pour récupérer un argument ou valeur par défaut
arg <- function(key, default = NULL) {
  hit <- grep(paste0("^", key, "="), args, value = TRUE)
  if (length(hit) == 0) return(default)
  sub(paste0("^", key, "="), "", hit[[1]])
}

# Auto-defaults: prefer Elbe dataset if it exists, otherwise fallback to BTC.
auto_defaults <- function() {
  elbe_path <- "data/Elbe_Discharge.csv"
  btc_path <- "data/btc_hourly_ohclv_ta.csv"

  if (file.exists(elbe_path)) {
    list(
      data_path = elbe_path,
      datetime_col = "Date",
      discharge_col = "Discharge",
      tz = "UTC",
      out_dir = "outputs"
    )
  } else {
    list(
      data_path = btc_path,
      datetime_col = "DATETIME",
      discharge_col = "CLOSE",
      tz = "UTC",
      out_dir = "outputs"
    )
  }
}

# Build config from args + defaults
build_config <- function() {
  dflt <- auto_defaults()

  cfg <- list(
    data_path     = arg("data", dflt$data_path),
    datetime_col  = arg("datetime_col", dflt$datetime_col),
    discharge_col = arg("discharge_col", dflt$discharge_col),
    tz            = arg("tz", dflt$tz),
    out_dir       = arg("out", dflt$out_dir)
  )

  ensure_dir(cfg$out_dir)
  cfg
}

# -------------------------------
# 2️⃣ Lecture des données
# -------------------------------
load_data <- function(cfg) {
  d <- read_elbe(
    cfg$data_path,
    datetime_col  = cfg$datetime_col,
    discharge_col = cfg$discharge_col,
    tz            = cfg$tz
  )

  # Quick check (lightweight)
  suppressWarnings({
    print(dplyr::glimpse(d))
  })
  suppressWarnings({
    print(summary(d$Q))
  })

  d
}
