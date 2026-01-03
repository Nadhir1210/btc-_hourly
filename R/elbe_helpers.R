suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(lubridate)
  library(tidyr)
})

ensure_dir <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE)
  invisible(path)
}

read_elbe <- function(path, datetime_col = "datetime", discharge_col = "Q", tz = "UTC") {
  if (!file.exists(path)) {
    stop(
      "Data file not found: ", normalizePath(path, winslash = "/", mustWork = FALSE), "\n",
      "Put your dataset at the expected path (e.g., data/btc_hourly_ohclv_ta.csv) or pass data=... when running."
    )
  }

  df <- readr::read_csv(path, show_col_types = FALSE, progress = FALSE)

  if (!datetime_col %in% names(df)) stop("Missing datetime column: ", datetime_col)
  if (!discharge_col %in% names(df)) stop("Missing discharge column: ", discharge_col)

  dt_raw <- df[[datetime_col]]
  dt <- dt_raw

  if (!inherits(dt_raw, "POSIXt")) {
    dt <- suppressWarnings(
      parse_date_time(
        as.character(dt_raw),
        orders = c(
          "Ymd HMS", "Ymd HM", "Ymd",
          "dmY HMS", "dmY HM", "dmY",
          "mdY HMS", "mdY HM", "mdY"
        ),
        tz = tz
      )
    )
  }

  out <- df %>%
    transmute(
      datetime = dt,
      Q = as.numeric(.data[[discharge_col]]),
      across(setdiff(names(df), c(datetime_col, discharge_col)), identity)
    ) %>%
    filter(!is.na(datetime), is.finite(Q)) %>%
    arrange(datetime)

  out
}

stats_table <- function(x) {
  x <- x[is.finite(x)]
  if (length(x) == 0) stop("No finite values provided")

  tibble::tibble(
    min = min(x),
    q25 = quantile(x, 0.25, names = FALSE),
    median = median(x),
    mean = mean(x),
    geom_mean = {
      xp <- x[x > 0]
      if (length(xp) == 0) NA_real_ else exp(mean(log(xp)))
    },
    q75 = quantile(x, 0.75, names = FALSE),
    max = max(x)
  )
}

identify_dry_wet_years <- function(df, n = 2) {
  annual <- df %>%
    mutate(year = lubridate::year(datetime)) %>%
    group_by(year) %>%
    summarise(mean_Q = mean(Q, na.rm = TRUE), median_Q = median(Q, na.rm = TRUE), .groups = "drop") %>%
    arrange(mean_Q)

  list(
    annual = annual,
    dry = annual %>% slice_head(n = n),
    wet = annual %>% slice_tail(n = n)
  )
}

seasonal_signature <- function(df) {
  df %>%
    mutate(
      year = lubridate::year(datetime),
      season = case_when(
        lubridate::month(datetime) %in% c(12, 1, 2) ~ "winter",
        lubridate::month(datetime) %in% c(6, 7, 8) ~ "summer",
        TRUE ~ "other"
      )
    ) %>%
    filter(season %in% c("winter", "summer")) %>%
    group_by(year, season) %>%
    summarise(mean_Q = mean(Q, na.rm = TRUE), .groups = "drop") %>%
    tidyr::pivot_wider(names_from = season, values_from = mean_Q) %>%
    mutate(winter_minus_summer = winter - summer) %>%
    arrange(winter_minus_summer)
}

fit_distribution_models <- function(x) {
  # Fits common positive-support distributions and returns AIC table + fit objects.
  suppressPackageStartupMessages(library(MASS))

  x <- x[is.finite(x) & x > 0]
  if (length(x) < 10) stop("Need at least 10 positive observations")

  safe_fit <- function(expr) {
    tryCatch(expr, error = function(e) NULL)
  }

  fits <- list(
    lognormal = safe_fit(MASS::fitdistr(x, "lognormal")),
    gamma = safe_fit(MASS::fitdistr(x, "gamma")),
    weibull = safe_fit(MASS::fitdistr(x, "weibull"))
  )
  fits <- fits[!vapply(fits, is.null, logical(1))]
  if (length(fits) == 0) stop("No models could be fit")

  aic <- purrr::imap_dfr(fits, function(f, name) {
    k <- length(f$estimate)
    tibble::tibble(model = name, logLik = f$loglik, AIC = -2 * f$loglik + 2 * k)
  }) %>%
    arrange(AIC)

  list(aic = aic, fits = fits)
}

ks_gof <- function(x, fit_name, fit) {
  # KS test against fitted distribution (heuristic; parameters estimated from data).
  x <- x[is.finite(x) & x > 0]
  if (length(x) < 10) return(tibble::tibble(model = fit_name, ks_p_value = NA_real_))

  pfun <- switch(
    fit_name,
    lognormal = function(z) plnorm(z, meanlog = fit$estimate[["meanlog"]], sdlog = fit$estimate[["sdlog"]]),
    gamma = function(z) pgamma(z, shape = fit$estimate[["shape"]], rate = fit$estimate[["rate"]]),
    weibull = function(z) pweibull(z, shape = fit$estimate[["shape"]], scale = fit$estimate[["scale"]]),
    NULL
  )
  if (is.null(pfun)) return(tibble::tibble(model = fit_name, ks_p_value = NA_real_))

  out <- tryCatch(stats::ks.test(x, pfun), error = function(e) NULL)
  tibble::tibble(model = fit_name, ks_p_value = if (is.null(out)) NA_real_ else unname(out$p.value))
}

qq_data <- function(y) {
  y <- y[is.finite(y)]
  tibble::tibble(sample = sort(y), theo = qnorm(stats::ppoints(length(y))))
}
