# Minimal example analysis for btc_hourly_ohclv_ta.csv

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
})

csv_path <- "btc_hourly_ohclv_ta.csv"
stopifnot(file.exists(csv_path))

# Read as-is; adjust col_types if you know the schema
df <- readr::read_csv(csv_path, show_col_types = FALSE)

cat("Rows:", nrow(df), "\n")
cat("Cols:", ncol(df), "\n\n")

print(glimpse(df))

# Try to find a likely timestamp column
time_candidates <- intersect(names(df), c("time", "timestamp", "date", "datetime", "open_time", "close_time"))
if (length(time_candidates) > 0) {
  cat("\nPossible time columns:", paste(time_candidates, collapse = ", "), "\n")
}

# Basic numeric summary
num_cols <- names(df)[vapply(df, is.numeric, logical(1))]
if (length(num_cols) > 0) {
  cat("\nNumeric columns summary (min/median/max):\n")
  summary_tbl <- df |>
    summarise(across(all_of(num_cols), list(
      min = ~min(.x, na.rm = TRUE),
      median = ~median(.x, na.rm = TRUE),
      max = ~max(.x, na.rm = TRUE)
    ), .names = "{.col}__{.fn}"))
  print(summary_tbl)
} else {
  cat("\nNo numeric columns detected.\n")
}
