/**
 */
package moobench.benchmark;

import java.io.File;
import com.beust.jcommander.Parameter;
import com.beust.jcommander.converters.FileConverter;
import kieker.monitoring.core.controller.MonitoringController;
import kieker.monitoring.core.registry.ControlFlowRegistry;
import kieker.monitoring.core.registry.SessionRegistry;
import de.dagere.kopeme.kieker.record.DurationRecord;

/**
 * @author Reiner Jung
 */
public class BenchmarkParameter {

    private static final kieker.monitoring.core.controller.IMonitoringController _kieker_sourceInstrumentation_controller = kieker.monitoring.core.controller.MonitoringController.getInstance();

    private static final kieker.monitoring.timer.ITimeSource _kieker_sourceInstrumentation_TIME_SOURCE = _kieker_sourceInstrumentation_controller.getTimeSource();

    @Parameter(names = { "--total-calls", "-c" }, required = true, description = "Number of total method calls performed.")
    int totalCalls;

    @Parameter(names = { "--method-time", "-m" }, required = true, description = "Time a method call takes.")
    int methodTime;

    @Parameter(names = { "--total-threads", "-t" }, required = true, description = "Number of threads started.")
    int totalThreads;

    @Parameter(names = { "--recursion-depth", "-d" }, required = true, description = "Depth of recursion performed.")
    int recursionDepth;

    @Parameter(names = { "--output-filename", "-o" }, required = true, converter = FileConverter.class, description = "Filename of results file. Output is appended if file exists.")
    File outputFile;

    @Parameter(names = { "--quickstart", "-q" }, required = false, description = "Skips initial garbage collection.")
    boolean quickstart;

    @Parameter(names = { "--force-terminate", "-f" }, required = false, description = "Forces a termination at the end of the benchmark.")
    boolean forceTerminate;

    @Parameter(names = { "--runnable", "-r" }, required = false, description = "Class implementing the Runnable interface. run() method is executed before the benchmark starts.")
    String runnableClassname;

    @Parameter(names = { "--application", "-a" }, required = false, description = "Class implementing the MonitoredClass interface.")
    String applicationClassname;

    @Parameter(names = { "--benchmark-thread", "-b" }, required = false, description = "Class implementing the BenchmarkingThread interface.")
    String benchmarkClassname;

    public int getTotalCalls() {
        final String _kieker_sourceInstrumentation_signature = "public int moobench.benchmark.BenchmarkParameter.getTotalCalls()";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return totalCalls;
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }

    public int getMethodTime() {
        final String _kieker_sourceInstrumentation_signature = "public int moobench.benchmark.BenchmarkParameter.getMethodTime()";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return methodTime;
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }

    public int getTotalThreads() {
        final String _kieker_sourceInstrumentation_signature = "public int moobench.benchmark.BenchmarkParameter.getTotalThreads()";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return totalThreads;
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }

    public int getRecursionDepth() {
        final String _kieker_sourceInstrumentation_signature = "public int moobench.benchmark.BenchmarkParameter.getRecursionDepth()";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return recursionDepth;
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }

    public File getOutputFile() {
        final String _kieker_sourceInstrumentation_signature = "public java.io.File moobench.benchmark.BenchmarkParameter.getOutputFile()";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return outputFile;
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }

    public boolean isQuickstart() {
        final String _kieker_sourceInstrumentation_signature = "public boolean moobench.benchmark.BenchmarkParameter.isQuickstart()";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return quickstart;
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }

    public boolean isForceTerminate() {
        final String _kieker_sourceInstrumentation_signature = "public boolean moobench.benchmark.BenchmarkParameter.isForceTerminate()";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return forceTerminate;
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }

    public String getRunnableClassname() {
        final String _kieker_sourceInstrumentation_signature = "public java.lang.String moobench.benchmark.BenchmarkParameter.getRunnableClassname()";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return runnableClassname;
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }

    public String getApplicationClassname() {
        final String _kieker_sourceInstrumentation_signature = "public java.lang.String moobench.benchmark.BenchmarkParameter.getApplicationClassname()";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return applicationClassname;
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }

    public String getBenchmarkClassname() {
        final String _kieker_sourceInstrumentation_signature = "public java.lang.String moobench.benchmark.BenchmarkParameter.getBenchmarkClassname()";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return benchmarkClassname;
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }
}
