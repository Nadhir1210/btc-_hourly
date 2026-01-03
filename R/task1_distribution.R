source("R/task0_prep.R")

cfg <- build_config()
d <- load_data(cfg)

# ---- Stats table (compact) ----
out_dir <- cfg$out_dir

stats <- stats_table(d$Q) %>%
  mutate(
    start = min(d$datetime),
    end = max(d$datetime),
    n = nrow(d)
  ) %>%
  relocate(n, start, end)

readr::write_csv(stats, file.path(out_dir, "task1_stats.csv"))

# ---- Model comparison (AIC + KS p-values) ----
models <- fit_distribution_models(d$Q)
ks <- purrr::imap_dfr(models$fits, ~ ks_gof(d$Q, .y, .x))
model_table <- models$aic %>%
  left_join(ks, by = c("model"))

readr::write_csv(model_table, file.path(out_dir, "task1_model_comparison.csv"))

# ---- Plots (max 4) ----
# 1) Histogram + density (raw)
p1 <- ggplot(d, aes(Q)) +
  geom_histogram(aes(y = after_stat(density)), bins = 60) +
  geom_density(linewidth = 0.8) +
  theme_minimal() +
  labs(title = "Discharge distribution (raw)", x = "Q", y = "Density")

ggsave(file.path(out_dir, "task1_plot1_hist_density_raw.png"), p1, width = 7, height = 4.5, dpi = 160)

# 2) ECDF (raw) for tail/shape
p2 <- ggplot(d, aes(Q)) +
  stat_ecdf(linewidth = 0.8) +
  theme_minimal() +
  labs(title = "ECDF of discharge (raw)", x = "Q", y = "F(Q)")

ggsave(file.path(out_dir, "task1_plot2_ecdf_raw.png"), p2, width = 7, height = 4.5, dpi = 160)

# 3) QQ plot: log(Q) vs Normal
x <- d$Q
x <- x[is.finite(x) & x > 0]
qq_log <- qq_data(log(x))

p3 <- ggplot(qq_log, aes(theo, sample)) +
  geom_point(size = 0.8, alpha = 0.6) +
  geom_abline(slope = 1, intercept = 0) +
  theme_minimal() +
  labs(title = "QQ plot: log(Q) vs Normal", x = "Theoretical quantiles", y = "Sample quantiles")

ggsave(file.path(out_dir, "task1_plot3_qq_logQ.png"), p3, width = 7, height = 4.5, dpi = 160)

# 4) Density comparison: raw vs log-scale x-axis (visual aid)
p4 <- ggplot(d, aes(Q)) +
  geom_density(linewidth = 0.9) +
  scale_x_log10() +
  theme_minimal() +
  labs(title = "Density of discharge (log10 x-axis)", x = "Q (log10 scale)", y = "Density")

ggsave(file.path(out_dir, "task1_plot4_density_logx.png"), p4, width = 7, height = 4.5, dpi = 160)

cat("Task 1 done. Wrote:\n")
cat("- ", file.path(out_dir, "task1_stats.csv"), "\n", sep = "")
cat("- ", file.path(out_dir, "task1_model_comparison.csv"), "\n", sep = "")
cat("- 4 plots in ", out_dir, "\n", sep = "")
