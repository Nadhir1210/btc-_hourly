# Run Task 1 + Task 2 analysis scripts.
# Usage (examples):
#   Rscript run_all.R
#   Rscript run_all.R data=data/elbe_discharge.csv datetime_col=DateTime discharge_col=Discharge out=outputs

args <- commandArgs(trailingOnly = TRUE)
arg <- function(key, default = NULL) {
  hit <- grep(paste0("^", key, "="), args, value = TRUE)
  if (length(hit) == 0) return(default)
  sub(paste0("^", key, "="), "", hit[[1]])
}

# Defaults (auto-selected inside R/task0_prep.R if not provided)
data_path <- arg("data", "")
datetime_col <- arg("datetime_col", "")
discharge_col <- arg("discharge_col", "")
tz <- arg("tz", "")
out_dir <- arg("out", "")

common_args <- character(0)
if (nzchar(data_path)) common_args <- c(common_args, paste0("data=", data_path))
if (nzchar(datetime_col)) common_args <- c(common_args, paste0("datetime_col=", datetime_col))
if (nzchar(discharge_col)) common_args <- c(common_args, paste0("discharge_col=", discharge_col))
if (nzchar(tz)) common_args <- c(common_args, paste0("tz=", tz))
if (nzchar(out_dir)) common_args <- c(common_args, paste0("out=", out_dir))

cat("Running Task 1...\n")
rscript <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript")
status1 <- system2(rscript, args = c("R/task1_distribution.R", common_args))
if (!is.null(status1) && status1 != 0) stop("Task 1 failed with exit code ", status1)

cat("\nRunning Task 2...\n")
status2 <- system2(rscript, args = c("R/task2_dry_wet_years.R", common_args))
if (!is.null(status2) && status2 != 0) stop("Task 2 failed with exit code ", status2)

cat("\nAll done. Outputs in:", out_dir, "\n")
