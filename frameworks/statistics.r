############################################
# R - script to collect all moobench results
############################################

# these values are here only as documentation. The parameters are set by measure.sh
#rm(list=ls(all=TRUE))
#data_fn="data/"
#folder_fn="results-benchmark-binary"
#results_fn=paste(data_fn,folder_fn,"/raw",sep="")
#outtxt_fn=paste(data_fn,folder_fn,"/results-text.txt",sep="")
#results_fn="raw"
#out_yam_fn="results.yaml"

#########
# These are configuration parameters which are automatically prepended to this file by the measure.sh script.
# Therefore, they must not be set here. The following lines only serve as documentation.
#configs.loop=10
#configs.recursion=c(10)
#configs.labels=c("No Probe","Inactive Probe","Collecting Data","Writing Data (ASCII)", "Writing Data (Bin)")
#configs.framework_name="kieker-java"
#results.count=2000000
#results.skip=1000000

#bars.minval=500
#bars.maxval=600


##########
# Process configuration

# divisor 1 = nano, 1000 = micro, 1000000 = milli seconds
timeUnit <- 1000

# if TRUE, drop the smallest and largest 0.5% of measurement values of each run
drop_outliers <- False
outlierFraction <- 0.005

# number of Kieker writer configurations
numberOfWriters <- length(configs.labels)
recursion_depth <- configs.recursion

# number of measurement values after warm-up, but before optional outlier removal
numberOfMeasurementValuesPerRun <- results.count - results.skip

# number of values dropped at each end of each run
numberOfOutliersPerSide <- if (drop_outliers) {
   floor(numberOfMeasurementValuesPerRun * outlierFraction)
} else {
   0
}

# number of values actually used for interpretation
numberOfValuesPerRun <- numberOfMeasurementValuesPerRun - 2 * numberOfOutliersPerSide
numberOfValues <- configs.loop * numberOfValuesPerRun

numbers <- c(1:(numberOfValues))
resultDimensionNames <- list(configs.labels, numbers)

# result values
resultsBIG <- array(dim=c(numberOfWriters, numberOfValues), dimnames=resultDimensionNames)

##########
# Create result

## "[ recursion , config , loop ]"

numOfRowsToRead <- numberOfMeasurementValuesPerRun

for (writer_idx in configs.indices) {
   recordsPerSecond = c()
   rpsLastDuration = 0
   rpsCount = 0
   array_idx <- writer_idx + 1

   # loop
   for (loop_counter in (1:configs.loop)) {
      results_fn_filepath <- paste(results_fn, "-", loop_counter, "-", recursion_depth, "-", writer_idx, ".csv", sep="")
      message(results_fn_filepath)
      results <- read.csv2(
         results_fn_filepath,
         nrows=numOfRowsToRead,
         skip=results.skip,
         quote="",
         colClasses=c("NULL","numeric", "numeric", "numeric"),
         comment.char="",
         col.names=c("thread_id", "duration_nsec", "gc", "t"),
         header=FALSE
      )

      values <- results[["duration_nsec"]]

      # Remove smallest and largest 0.5% independently for each run.
      if (drop_outliers && numberOfOutliersPerSide > 0) {
         values <- sort(values)
         values <- values[
            (numberOfOutliersPerSide + 1):
            (length(values) - numberOfOutliersPerSide)
         ]
      }

      trx_idx <- (
         ((loop_counter - 1) * numberOfValuesPerRun + 1):
         (loop_counter * numberOfValuesPerRun)
      )

      resultsBIG[array_idx,trx_idx] <- values
   }
}

qnorm_value <- qnorm(0.975)

# print results
printDimensionNames <- list(c("mean","sd","ci95%","md25%","md50%","md75%","max","min"), c(1:numberOfWriters))
# row number == number of computed result values, e.g., mean, min, max
printvalues <- matrix(nrow=8, ncol=numberOfWriters, dimnames=printDimensionNames)

for (writer_idx in configs.indices) {
   idx_mult <- c(1:numberOfValues)

   array_idx <- writer_idx + 1

   valuesBIG <- resultsBIG[array_idx,idx_mult] / timeUnit / recursion_depth

   printvalues["mean",array_idx] <- mean(valuesBIG)
   printvalues["sd",array_idx] <- sd(valuesBIG)
   printvalues["ci95%",array_idx] <- qnorm_value*sd(valuesBIG)/sqrt(length(valuesBIG))
   printvalues[c("md25%","md50%","md75%"),array_idx] <- quantile(valuesBIG, probs=c(0.25, 0.5, 0.75))
   printvalues["max",array_idx] <- max(valuesBIG)
   printvalues["min",array_idx] <- min(valuesBIG)
}

resultstext <- formatC(printvalues,format="f",digits=4,width=8)

print(resultstext)


currentTime <- as.numeric(Sys.time())

mktext <- function(value) {
    if (is.na(value)) {
       return(".NAN")
    } else {
       return(format(value, scientific=TRUE))
    }
}

formatCount <- function(value) {
   format(value, scientific=FALSE, trim=TRUE, big.mark=",")
}


##########
# Print benchmark settings and number of values

timeUnitName <- switch(
   as.character(timeUnit),
   "1" = "nanoseconds",
   "1000" = "microseconds",
   "1000000" = "milliseconds",
   stop("Unsupported timeUnit")
)

warmupFraction <- results.skip / results.count

# The following counts are per writer configuration, across all runs.

# Recursion chains
overallRecursionChains <- configs.loop * results.count
warmupRecursionChains <- configs.loop * results.skip
measurementRecursionChains <- overallRecursionChains - warmupRecursionChains

outlierRecursionChains <- configs.loop *
   2 *
   numberOfOutliersPerSide

interpretationRecursionChains <- measurementRecursionChains - outlierRecursionChains

# Method calls
overallMethodCalls <- overallRecursionChains * recursion_depth
warmupMethodCalls <- warmupRecursionChains * recursion_depth
measurementMethodCalls <- measurementRecursionChains * recursion_depth
outlierMethodCalls <- outlierRecursionChains * recursion_depth
interpretationMethodCalls <- interpretationRecursionChains * recursion_depth


write(sprintf(
   "run time per method call (not recursion chain!) in %s",
   timeUnitName
), stdout())

write("", stdout())

write("settings:", stdout())
write(sprintf(
   "  framework: %s",
   configs.framework_name
), stdout())
write(sprintf(
   "  runs: %d",
   configs.loop
), stdout())
write(sprintf(
   "  recursion depth: %d",
   recursion_depth
), stdout())
write(sprintf(
   "  recursion chains per run: %s",
   formatCount(results.count)
), stdout())
write(sprintf(
   "  dropped warm-up chains per run: %s (%.1f%%)",
   formatCount(results.skip),
   warmupFraction * 100
), stdout())

if (drop_outliers) {
   write(sprintf(
      "  drop outliers: TRUE --> outliers dropped per run (%.1f%% smallest + %.1f%% largest, i.e., %s of %s chains)",
      outlierFraction * 100,
      outlierFraction * 100,
      formatCount(2 * numberOfOutliersPerSide),
      formatCount(numberOfMeasurementValuesPerRun)
   ), stdout())
} else {
   write("  drop outliers: FALSE", stdout())
}

write("", stdout())

write('Statistics in terms of "recursion chains" -- recursion chains per configuration across all runs:', stdout())
write(sprintf(
   "  overall recursion chains: %s (recursion chains per run * runs)",
   formatCount(overallRecursionChains)
), stdout())
write(sprintf(
   "  dropped warm-up recursion chains: %s (%.1f%%)",
   formatCount(warmupRecursionChains),
   warmupFraction * 100
), stdout())
write(sprintf(
   "  remaining measurement recursion chains: %s",
   formatCount(measurementRecursionChains)
), stdout())

if (drop_outliers) {
   write(sprintf(
      "  dropped from measurement recursion chains as outliers (%.1f%% smallest + %.1f%% largest): %s",
      outlierFraction * 100,
      outlierFraction * 100,
      formatCount(outlierRecursionChains)
   ), stdout())
}

write(sprintf(
   "  recursion chains finally used for interpretation: %s",
   formatCount(interpretationRecursionChains)
), stdout())

write("", stdout())

write('Statistics in terms of "method calls" -- method calls per configuration across all runs:', stdout())
write(sprintf(
   "  overall method calls: %s (recursion depth * recursion chains per run * runs)",
   formatCount(overallMethodCalls)
), stdout())
write(sprintf(
   "  dropped warm-up method calls: %s (%.1f%%)",
   formatCount(warmupMethodCalls),
   warmupFraction * 100
), stdout())
write(sprintf(
   "  remaining measurement method calls: %s",
   formatCount(measurementMethodCalls)
), stdout())

if (drop_outliers) {
   write(sprintf(
      "  dropped from measurement method calls as outliers (%.1f%% smallest + %.1f%% largest): %s",
      outlierFraction * 100,
      outlierFraction * 100,
      formatCount(outlierMethodCalls)
   ), stdout())
}

write(sprintf(
   "  method calls used for interpretation: %s",
   formatCount(interpretationMethodCalls)
), stdout())


##########
# Write YAML results

write(paste("kind:", configs.framework_name), file=out_yaml_fn,append=FALSE)
write("experiments:", file=out_yaml_fn, append=TRUE)
write(paste("- timestamp:", currentTime), file=out_yaml_fn, append=TRUE)
write("  measurements:", file=out_yaml_fn, append=TRUE)

for (writer_idx in configs.indices) {
   array_idx <- writer_idx + 1
   write(paste("    ", configs.labels[array_idx], ": [",
      mktext(printvalues["mean",array_idx]), ",",
      mktext(printvalues["sd",array_idx]), ",",
      mktext(printvalues["ci95%",array_idx]), ",",
      mktext(printvalues["md25%",array_idx]), ",",
      mktext(printvalues["md50%",array_idx]), ",",
      mktext(printvalues["md75%",array_idx]), ",",
      mktext(printvalues["max",array_idx]), ",",
      mktext(printvalues["min",array_idx]), "]"), file=out_yaml_fn, append=TRUE)
}
# end
