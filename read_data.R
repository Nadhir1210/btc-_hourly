suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
})

csv_path <- "btc_hourly_ohclv_ta.csv"

if (!file.exists(csv_path)) {
  stop("File not found: ", normalizePath(csv_path, winslash = "/", mustWork = FALSE))
}

df <- read_csv(
  csv_path,
  show_col_types = FALSE,
  progress = FALSE
)

cat("\nLoaded:", csv_path, "\n")
cat("Rows:", nrow(df), " Columns:", ncol(df), "\n\n")

cat("Column names:\n")
print(names(df))

cat("\nFirst 6 rows:\n")
print(head(df, 6))

cat("\nStructure:\n")
print(str(df))

# Basic missingness summary
na_by_col <- sapply(df, function(x) sum(is.na(x)))
na_by_col <- sort(na_by_col, decreasing = TRUE)
cat("\nNA counts (top 10):\n")
print(head(na_by_col, 10))

# Quick time range (if columns exist)
if ("DATETIME" %in% names(df)) {
  # Parse as POSIXct; tolerate milliseconds
  dt <- suppressWarnings(as.POSIXct(df$DATETIME, tz = "UTC"))
  if (all(!is.na(dt))) {
    cat("\nDATETIME range (UTC):\n")
    cat("  min:", format(min(dt), "%Y-%m-%d %H:%M:%S"), "\n")
    cat("  max:", format(max(dt), "%Y-%m-%d %H:%M:%S"), "\n")
  } else {
    cat("\nDATETIME present but could not be parsed cleanly (check format).\n")
  }
}

if ("UNIX_TIMESTAMP" %in% names(df)) {
  ts <- df$UNIX_TIMESTAMP
  if (is.numeric(ts)) {
    cat("\nUNIX_TIMESTAMP range:\n")
    cat("  min:", min(ts, na.rm = TRUE), "\n")
    cat("  max:", max(ts, na.rm = TRUE), "\n")
  }
}
