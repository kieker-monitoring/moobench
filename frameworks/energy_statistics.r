############################################
# energy.r - analyse MooBench energy results
############################################

# These values are prepended by runEnergyStatistics in common-functions.sh.
# The following lines only serve as documentation.
#energy_fn="results-Kieker-java/raw-energy.csv"
#out_report_fn="results-Kieker-java/energy-report.txt"
#out_csv_fn="results-Kieker-java/energy-summary.csv"
#configs.labels=c("No Probe","Inactive Probe","Collecting Data","Writing Data (ASCII)", "Writing Data (Bin)")
#configs.indices=c(0,1,2,4,5)
#configs.framework_name="Kieker-java"
#configs.threads=1
#configs.recursion=10
#configs.rapl_max_range=262143328850   (0 if unknown)
#results.count=2000000

if (!file.exists(energy_fn)) {
  stop(paste("Energy file not found:", energy_fn))
}

##########
# Read raw energy file

# Read every column as text: the file may contain a repeated header line
# per run, and the header may have more columns than the data rows.
raw <- read.table(
  energy_fn,
  sep = ";",
  header = FALSE,
  fill = TRUE,
  quote = "",
  comment.char = "",
  colClasses = "character",
  col.names = paste0("V", 1:6)
)

# drop header lines and empty lines
raw <- raw[raw$V1 != "iteration" & raw$V1 != "", ]

# column 1 holds the result file name: raw-<loop>-<depth>-<config>.csv
name_pattern <- "^.*-([0-9]+)-([0-9]+)-([0-9]+)\\.csv$"

energy <- data.frame(
  loop = as.integer(sub(name_pattern, "\\1", raw$V1)),
  config = as.integer(sub(name_pattern, "\\3", raw$V1)),
  start_uj = as.numeric(raw$V2),
  end_uj = as.numeric(raw$V3),
  time_ms = as.numeric(raw$V4)
)
energy <- energy[energy$config %in% configs.indices, ]
energy <- energy[order(energy$config, energy$loop), ]

# RAPL energy_uj wraps around to 0 at max_energy_range_uj
energy$delta_uj <- energy$end_uj - energy$start_uj
if (configs.rapl_max_range > 0) {
  wrapped <- energy$delta_uj < 0
  energy$delta_uj[wrapped] <- energy$delta_uj[wrapped] + configs.rapl_max_range
}

##########
# Per-trial values

calls_per_run <- results.count * configs.threads # top-level calls (recursion chains)
method_calls_per_run <- calls_per_run * configs.recursion # individual method calls

energy$label <- configs.labels[energy$config + 1]
energy$time_s <- energy$time_ms / 1000
energy$energy_j <- energy$delta_uj / 1e6
energy$power_w <- energy$energy_j / energy$time_s
energy$uj_per_chain <- energy$delta_uj / calls_per_run
energy$nj_per_method <- energy$delta_uj * 1000 / method_calls_per_run

##########
# Per-configuration summary

qnorm_value <- qnorm(0.975)
ci95 <- function(x) {
  if (length(x) > 1) qnorm_value * sd(x) / sqrt(length(x)) else NA
}
cv <- function(x) if (length(x) > 1) 100 * sd(x) / mean(x) else NA

baseline_runs <- energy[energy$config == 0, ]
has_baseline <- nrow(baseline_runs) > 0

summary_rows <- list()
for (writer_idx in configs.indices) {
  runs <- energy[energy$config == writer_idx, ]
  if (nrow(runs) == 0) {
    warning(paste("No energy values for configuration", writer_idx))
    next
  }
  row <- data.frame(
    config = writer_idx,
    label = configs.labels[writer_idx + 1],
    runs = nrow(runs),
    total_time_s = sum(runs$time_s),
    total_energy_j = sum(runs$energy_j),
    mean_time_s = mean(runs$time_s),
    mean_energy_j = mean(runs$energy_j),
    median_energy_j = median(runs$energy_j),
    sd_energy_j = if (nrow(runs) > 1) sd(runs$energy_j) else NA,
    ci95_energy_j = ci95(runs$energy_j),
    cv_energy_pct = cv(runs$energy_j),
    min_energy_j = min(runs$energy_j),
    max_energy_j = max(runs$energy_j),
    mean_power_w = mean(runs$power_w),
    uj_per_chain = mean(runs$uj_per_chain),
    nj_per_method = mean(runs$nj_per_method),
    time_energy_cor = if (
      nrow(runs) > 2 && sd(runs$time_s) > 0 && sd(runs$energy_j) > 0
    ) {
      cor(runs$time_s, runs$energy_j)
    } else {
      NA
    }
  )

  if (has_baseline) {
    e0 <- mean(baseline_runs$energy_j)
    t0 <- mean(baseline_runs$time_s)
    p0 <- mean(baseline_runs$power_w)
    row$energy_overhead_j <- row$mean_energy_j - e0
    row$energy_overhead_pct <- 100 * (row$mean_energy_j - e0) / e0
    row$time_overhead_pct <- 100 * (row$mean_time_s - t0) / t0
    row$power_overhead_pct <- 100 * (row$mean_power_w - p0) / p0
    # extra energy per monitored top-level call compared to no instrumentation
    row$overhead_uj_per_chain <- row$energy_overhead_j * 1e6 / calls_per_run
    # Welch t-test: is the energy difference to the baseline significant?
    row$p_value_vs_baseline <- if (
      writer_idx != 0 && nrow(runs) > 1 && nrow(baseline_runs) > 1
    ) {
      t.test(runs$energy_j, baseline_runs$energy_j)$p.value
    } else {
      NA
    }
  }

  summary_rows[[length(summary_rows) + 1]] <- row
}
result <- do.call(rbind, summary_rows)

##########
# Write report

options(width = 250)
fmt <- function(df) format(df, digits = 4, scientific = FALSE)

sink(out_report_fn)

cat("MooBench energy report\n")
cat("======================\n\n")
cat(sprintf("framework:               %s\n", configs.framework_name))
cat(sprintf("recursion depth:         %d\n", configs.recursion))
cat(sprintf("threads:                 %d\n", configs.threads))
cat(sprintf(
  "calls per run:           %s\n",
  format(calls_per_run, big.mark = ",", scientific = FALSE)
))
cat(sprintf(
  "method calls per run:    %s\n",
  format(method_calls_per_run, big.mark = ",", scientific = FALSE)
))
cat(
  "energy source:           CPU package (RAPL), whole system, not only the benchmark\n"
)
cat(
  "note:                    energy and time cover the whole run including warm-up\n\n"
)

cat("1. Per trial\n")
cat("------------\n")
print(
  fmt(energy[, c(
    "config",
    "label",
    "loop",
    "time_s",
    "energy_j",
    "power_w",
    "uj_per_chain",
    "nj_per_method"
  )]),
  row.names = FALSE
)
cat("\n")

cat("2. Totals per configuration\n")
cat("---------------------------\n")
print(
  fmt(result[, c("config", "label", "runs", "total_time_s", "total_energy_j")]),
  row.names = FALSE
)
cat(sprintf(
  "\nwhole experiment: %.3f s, %.3f J\n\n",
  sum(energy$time_s),
  sum(energy$energy_j)
))

cat("3. Statistics per configuration (over runs)\n")
cat("-------------------------------------------\n")
print(
  fmt(result[, c(
    "config",
    "label",
    "mean_time_s",
    "mean_energy_j",
    "median_energy_j",
    "sd_energy_j",
    "ci95_energy_j",
    "cv_energy_pct",
    "min_energy_j",
    "max_energy_j"
  )]),
  row.names = FALSE
)
cat("\n")
print(
  fmt(result[, c(
    "config",
    "label",
    "mean_power_w",
    "uj_per_chain",
    "nj_per_method",
    "time_energy_cor"
  )]),
  row.names = FALSE
)
cat("\n")

if (has_baseline) {
  cat("4. Overhead compared to configuration 0 (no instrumentation)\n")
  cat("------------------------------------------------------------\n")
  print(
    fmt(result[, c(
      "config",
      "label",
      "energy_overhead_j",
      "energy_overhead_pct",
      "time_overhead_pct",
      "power_overhead_pct",
      "overhead_uj_per_chain",
      "p_value_vs_baseline"
    )]),
    row.names = FALSE
  )
  cat("\n")
  cat(
    "energy_overhead_pct ~ time_overhead_pct  -> extra energy comes mostly from running longer\n"
  )
  cat(
    "power_overhead_pct clearly above 0       -> monitoring also draws more power while running\n"
  )
  cat(
    "p_value_vs_baseline < 0.05                -> difference to baseline is statistically significant\n"
  )
  cat(
    "cv_energy_pct high (> 5-10%)             -> noisy runs; use more loops or a quieter machine\n\n"
  )

  cat("Ranking by mean energy (lowest first)\n")
  ranked <- result[
    order(result$mean_energy_j),
    c("config", "label", "mean_energy_j", "energy_overhead_pct")
  ]
  print(fmt(ranked), row.names = FALSE)
} else {
  cat(
    "4. No baseline (configuration 0) in this run, overhead analysis skipped\n"
  )
}

sink()

##########
# Machine-readable summary and console output

write.table(
  result,
  file = out_csv_fn,
  sep = ";",
  row.names = FALSE,
  quote = FALSE
)

cat(readLines(out_report_fn), sep = "\n")

# end
