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
              final long _kieker_sourceInstrumentation_tin = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();;
        try {
            return totalCalls;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
        _kieker_sourceInstrumentation_getTotalCallsSum0+=_kieker_sourceInstrumentation_tout-_kieker_sourceInstrumentation_tin;
if (_kieker_sourceInstrumentation_getTotalCallsCounter0++%1000==0){
final String _kieker_sourceInstrumentation_signature = "public int moobench.benchmark.BenchmarkParameter.getTotalCalls()";
final long _kieker_sourceInstrumentation_calculatedTout=_kieker_sourceInstrumentation_tin+_kieker_sourceInstrumentation_getTotalCallsSum0;
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_calculatedTout));
_kieker_sourceInstrumentation_getTotalCallsSum0=0;}
;
        }
    }

    public int getMethodTime() {
              final long _kieker_sourceInstrumentation_tin = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();;
        try {
            return methodTime;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
        _kieker_sourceInstrumentation_getMethodTimeSum1+=_kieker_sourceInstrumentation_tout-_kieker_sourceInstrumentation_tin;
if (_kieker_sourceInstrumentation_getMethodTimeCounter1++%1000==0){
final String _kieker_sourceInstrumentation_signature = "public int moobench.benchmark.BenchmarkParameter.getMethodTime()";
final long _kieker_sourceInstrumentation_calculatedTout=_kieker_sourceInstrumentation_tin+_kieker_sourceInstrumentation_getMethodTimeSum1;
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_calculatedTout));
_kieker_sourceInstrumentation_getMethodTimeSum1=0;}
;
        }
    }

    public int getTotalThreads() {
              final long _kieker_sourceInstrumentation_tin = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();;
        try {
            return totalThreads;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
        _kieker_sourceInstrumentation_getTotalThreadsSum2+=_kieker_sourceInstrumentation_tout-_kieker_sourceInstrumentation_tin;
if (_kieker_sourceInstrumentation_getTotalThreadsCounter2++%1000==0){
final String _kieker_sourceInstrumentation_signature = "public int moobench.benchmark.BenchmarkParameter.getTotalThreads()";
final long _kieker_sourceInstrumentation_calculatedTout=_kieker_sourceInstrumentation_tin+_kieker_sourceInstrumentation_getTotalThreadsSum2;
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_calculatedTout));
_kieker_sourceInstrumentation_getTotalThreadsSum2=0;}
;
        }
    }

    public int getRecursionDepth() {
              final long _kieker_sourceInstrumentation_tin = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();;
        try {
            return recursionDepth;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
        _kieker_sourceInstrumentation_getRecursionDepthSum3+=_kieker_sourceInstrumentation_tout-_kieker_sourceInstrumentation_tin;
if (_kieker_sourceInstrumentation_getRecursionDepthCounter3++%1000==0){
final String _kieker_sourceInstrumentation_signature = "public int moobench.benchmark.BenchmarkParameter.getRecursionDepth()";
final long _kieker_sourceInstrumentation_calculatedTout=_kieker_sourceInstrumentation_tin+_kieker_sourceInstrumentation_getRecursionDepthSum3;
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_calculatedTout));
_kieker_sourceInstrumentation_getRecursionDepthSum3=0;}
;
        }
    }

    public File getOutputFile() {
              final long _kieker_sourceInstrumentation_tin = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();;
        try {
            return outputFile;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
        _kieker_sourceInstrumentation_getOutputFileSum4+=_kieker_sourceInstrumentation_tout-_kieker_sourceInstrumentation_tin;
if (_kieker_sourceInstrumentation_getOutputFileCounter4++%1000==0){
final String _kieker_sourceInstrumentation_signature = "public java.io.File moobench.benchmark.BenchmarkParameter.getOutputFile()";
final long _kieker_sourceInstrumentation_calculatedTout=_kieker_sourceInstrumentation_tin+_kieker_sourceInstrumentation_getOutputFileSum4;
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_calculatedTout));
_kieker_sourceInstrumentation_getOutputFileSum4=0;}
;
        }
    }

    public boolean isQuickstart() {
              final long _kieker_sourceInstrumentation_tin = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();;
        try {
            return quickstart;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
        _kieker_sourceInstrumentation_isQuickstartSum5+=_kieker_sourceInstrumentation_tout-_kieker_sourceInstrumentation_tin;
if (_kieker_sourceInstrumentation_isQuickstartCounter5++%1000==0){
final String _kieker_sourceInstrumentation_signature = "public boolean moobench.benchmark.BenchmarkParameter.isQuickstart()";
final long _kieker_sourceInstrumentation_calculatedTout=_kieker_sourceInstrumentation_tin+_kieker_sourceInstrumentation_isQuickstartSum5;
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_calculatedTout));
_kieker_sourceInstrumentation_isQuickstartSum5=0;}
;
        }
    }

    public boolean isForceTerminate() {
              final long _kieker_sourceInstrumentation_tin = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();;
        try {
            return forceTerminate;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
        _kieker_sourceInstrumentation_isForceTerminateSum6+=_kieker_sourceInstrumentation_tout-_kieker_sourceInstrumentation_tin;
if (_kieker_sourceInstrumentation_isForceTerminateCounter6++%1000==0){
final String _kieker_sourceInstrumentation_signature = "public boolean moobench.benchmark.BenchmarkParameter.isForceTerminate()";
final long _kieker_sourceInstrumentation_calculatedTout=_kieker_sourceInstrumentation_tin+_kieker_sourceInstrumentation_isForceTerminateSum6;
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_calculatedTout));
_kieker_sourceInstrumentation_isForceTerminateSum6=0;}
;
        }
    }

    public String getRunnableClassname() {
              final long _kieker_sourceInstrumentation_tin = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();;
        try {
            return runnableClassname;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
        _kieker_sourceInstrumentation_getRunnableClassnameSum7+=_kieker_sourceInstrumentation_tout-_kieker_sourceInstrumentation_tin;
if (_kieker_sourceInstrumentation_getRunnableClassnameCounter7++%1000==0){
final String _kieker_sourceInstrumentation_signature = "public java.lang.String moobench.benchmark.BenchmarkParameter.getRunnableClassname()";
final long _kieker_sourceInstrumentation_calculatedTout=_kieker_sourceInstrumentation_tin+_kieker_sourceInstrumentation_getRunnableClassnameSum7;
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_calculatedTout));
_kieker_sourceInstrumentation_getRunnableClassnameSum7=0;}
;
        }
    }

    public String getApplicationClassname() {
              final long _kieker_sourceInstrumentation_tin = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();;
        try {
            return applicationClassname;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
        _kieker_sourceInstrumentation_getApplicationClassnameSum8+=_kieker_sourceInstrumentation_tout-_kieker_sourceInstrumentation_tin;
if (_kieker_sourceInstrumentation_getApplicationClassnameCounter8++%1000==0){
final String _kieker_sourceInstrumentation_signature = "public java.lang.String moobench.benchmark.BenchmarkParameter.getApplicationClassname()";
final long _kieker_sourceInstrumentation_calculatedTout=_kieker_sourceInstrumentation_tin+_kieker_sourceInstrumentation_getApplicationClassnameSum8;
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_calculatedTout));
_kieker_sourceInstrumentation_getApplicationClassnameSum8=0;}
;
        }
    }

    public String getBenchmarkClassname() {
              final long _kieker_sourceInstrumentation_tin = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();;
        try {
            return benchmarkClassname;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
        _kieker_sourceInstrumentation_getBenchmarkClassnameSum9+=_kieker_sourceInstrumentation_tout-_kieker_sourceInstrumentation_tin;
if (_kieker_sourceInstrumentation_getBenchmarkClassnameCounter9++%1000==0){
final String _kieker_sourceInstrumentation_signature = "public java.lang.String moobench.benchmark.BenchmarkParameter.getBenchmarkClassname()";
final long _kieker_sourceInstrumentation_calculatedTout=_kieker_sourceInstrumentation_tin+_kieker_sourceInstrumentation_getBenchmarkClassnameSum9;
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_calculatedTout));
_kieker_sourceInstrumentation_getBenchmarkClassnameSum9=0;}
;
        }
    }

    private static int _kieker_sourceInstrumentation_getTotalCallsCounter0;

    private static int _kieker_sourceInstrumentation_getMethodTimeCounter1;

    private static int _kieker_sourceInstrumentation_getTotalThreadsCounter2;

    private static int _kieker_sourceInstrumentation_getRecursionDepthCounter3;

    private static int _kieker_sourceInstrumentation_getOutputFileCounter4;

    private static int _kieker_sourceInstrumentation_isQuickstartCounter5;

    private static int _kieker_sourceInstrumentation_isForceTerminateCounter6;

    private static int _kieker_sourceInstrumentation_getRunnableClassnameCounter7;

    private static int _kieker_sourceInstrumentation_getApplicationClassnameCounter8;

    private static int _kieker_sourceInstrumentation_getBenchmarkClassnameCounter9;

    private static long _kieker_sourceInstrumentation_getTotalCallsSum0;

    private static long _kieker_sourceInstrumentation_getMethodTimeSum1;

    private static long _kieker_sourceInstrumentation_getTotalThreadsSum2;

    private static long _kieker_sourceInstrumentation_getRecursionDepthSum3;

    private static long _kieker_sourceInstrumentation_getOutputFileSum4;

    private static long _kieker_sourceInstrumentation_isQuickstartSum5;

    private static long _kieker_sourceInstrumentation_isForceTerminateSum6;

    private static long _kieker_sourceInstrumentation_getRunnableClassnameSum7;

    private static long _kieker_sourceInstrumentation_getApplicationClassnameSum8;

    private static long _kieker_sourceInstrumentation_getBenchmarkClassnameSum9;
}
