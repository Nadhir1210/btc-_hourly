source("R/task0_prep.R")

cfg <- build_config()
out_dir <- cfg$out_dir
d <- load_data(cfg)

# Identify 2 dry + 2 wet years based on annual mean discharge
years <- identify_dry_wet_years(d, n = 2)
annual <- years$annual
sel <- bind_rows(
  years$dry %>% mutate(class = "dry"),
  years$wet %>% mutate(class = "wet")
) %>%
  arrange(mean_Q)

readr::write_csv(annual, file.path(out_dir, "task2_annual_summary.csv"))
readr::write_csv(sel, file.path(out_dir, "task2_selected_years.csv"))

# Seasonal signature table (winter vs summer contrast)
sig <- seasonal_signature(d)
readr::write_csv(sig, file.path(out_dir, "task2_seasonal_signature.csv"))

sel_years <- sel$year

# ---- Plots (max 4) ----
# 1) Faceted time series for selected years
p1 <- d %>%
  mutate(year = year(datetime)) %>%
  filter(year %in% sel_years) %>%
  ggplot(aes(datetime, Q)) +
  geom_line(linewidth = 0.25) +
  facet_wrap(~ year, scales = "free_x", ncol = 2) +
  theme_minimal() +
  labs(title = "Discharge time series: selected dry/wet years", x = NULL, y = "Q")

ggsave(file.path(out_dir, "task2_plot1_timeseries_selected_years.png"), p1, width = 7.5, height = 5.5, dpi = 160)

# 2) Annual cumulative sums (selected years)
p2 <- d %>%
  mutate(year = year(datetime)) %>%
  filter(year %in% sel_years) %>%
  group_by(year) %>%
  arrange(datetime, .by_group = TRUE) %>%
  mutate(idx = row_number(), cumQ = cumsum(Q)) %>%
  ungroup() %>%
  ggplot(aes(idx, cumQ, color = factor(year))) +
  geom_line(linewidth = 0.8) +
  theme_minimal() +
  labs(title = "Annual cumulative discharge (selected years)", x = "Index within year", y = "Cumulative Q", color = "Year")

ggsave(file.path(out_dir, "task2_plot2_cumulative_selected_years.png"), p2, width = 7.5, height = 4.8, dpi = 160)

# 3) Monthly boxplots for selected years (seasonality)
p3 <- d %>%
  mutate(year = year(datetime), month = month(datetime, label = TRUE, abbr = TRUE)) %>%
  filter(year %in% sel_years) %>%
  ggplot(aes(month, Q)) +
  geom_boxplot(outlier.alpha = 0.15) +
  facet_wrap(~ year, ncol = 2) +
  theme_minimal() +
  labs(title = "Monthly distribution within selected years", x = "Month", y = "Q")

ggsave(file.path(out_dir, "task2_plot3_monthly_boxplots.png"), p3, width = 7.5, height = 5.5, dpi = 160)

# 4) Monthly mean curve for selected years
p4 <- d %>%
  mutate(year = year(datetime), month = month(datetime)) %>%
  filter(year %in% sel_years) %>%
  group_by(year, month) %>%
  summarise(mean_Q = mean(Q, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(month, mean_Q, color = factor(year))) +
  geom_line(linewidth = 0.9) +
  scale_x_continuous(breaks = 1:12) +
  theme_minimal() +
  labs(title = "Seasonal pattern: monthly mean discharge", x = "Month", y = "Mean Q", color = "Year")

ggsave(file.path(out_dir, "task2_plot4_monthly_means.png"), p4, width = 7.5, height = 4.8, dpi = 160)

cat("Task 2 done. Wrote:\n")
cat("- ", file.path(out_dir, "task2_selected_years.csv"), "\n", sep = "")
cat("- ", file.path(out_dir, "task2_annual_summary.csv"), "\n", sep = "")
cat("- ", file.path(out_dir, "task2_seasonal_signature.csv"), "\n", sep = "")
cat("- 4 plots in ", out_dir, "\n", sep = "")
