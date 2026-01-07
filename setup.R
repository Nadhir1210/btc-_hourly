# Bootstrap + (re)store a reproducible R environment via renv

options(repos = c(CRAN = "https://cloud.r-project.org"))

message("Working directory: ", normalizePath(getwd(), winslash = "\\", mustWork = FALSE))

if (!requireNamespace("renv", quietly = TRUE)) {
  message("Installing renv...")
  install.packages("renv")
}

# Initialize renv if needed
if (!file.exists("renv.lock") || !dir.exists("renv")) {
  message("Initializing renv...")
  renv::init(bare = TRUE)
}

# Declare common packages used for data work (adjust to your needs)
required_packages <- c(
  "data.table",
  "readr",
  "dplyr",
  "ggplot2",
  "lubridate"
)

missing <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) {
  message("Installing packages: ", paste(missing, collapse = ", "))
  renv::install(missing)
}

message("Restoring/snapshotting lockfile...")
# If a lockfile already exists, restore ensures you match it; otherwise snapshot creates it.
if (file.exists("renv.lock")) {
  renv::restore(prompt = FALSE)
}
renv::snapshot(prompt = FALSE)

message("Done. renv status:")
print(renv::status())
