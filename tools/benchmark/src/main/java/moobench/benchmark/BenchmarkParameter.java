/**
 */
package moobench.benchmark;

import java.io.File;
import com.beust.jcommander.Parameter;
import com.beust.jcommander.converters.FileConverter;
import kieker.monitoring.core.controller.MonitoringController;
import kieker.monitoring.core.registry.ControlFlowRegistry;
import kieker.monitoring.core.registry.SessionRegistry;
import kieker.common.record.controlflow.OperationExecutionRecord;

/**
 * @author Reiner Jung
 */
public class BenchmarkParameter {

    private static final kieker.monitoring.core.controller.IMonitoringController _kieker_sourceInstrumentation_controller = kieker.monitoring.core.controller.MonitoringController.getInstance();

    private static final kieker.monitoring.timer.ITimeSource _kieker_sourceInstrumentation_TIME_SOURCE = _kieker_sourceInstrumentation_controller.getTimeSource();

    private static final String _kieker_sourceInstrumentation_VM_NAME = _kieker_sourceInstrumentation_controller.getHostname();

    private static final kieker.monitoring.core.registry.SessionRegistry _kieker_sourceInstrumentation_SESSION_REGISTRY = SessionRegistry.INSTANCE;

    private static final kieker.monitoring.core.registry.ControlFlowRegistry _kieker_sourceInstrumentation_controlFlowRegistry = ControlFlowRegistry.INSTANCE;

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
        if (!BenchmarkParameter._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            return totalCalls;
        }
        final String _kieker_sourceInstrumentation_signature = "public int moobench.benchmark.BenchmarkParameter.getTotalCalls()";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkParameter._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkParameter._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkParameter._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return totalCalls;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkParameter._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }

    public int getMethodTime() {
        if (!BenchmarkParameter._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            return methodTime;
        }
        final String _kieker_sourceInstrumentation_signature = "public int moobench.benchmark.BenchmarkParameter.getMethodTime()";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkParameter._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkParameter._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkParameter._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return methodTime;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkParameter._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }

    public int getTotalThreads() {
        if (!BenchmarkParameter._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            return totalThreads;
        }
        final String _kieker_sourceInstrumentation_signature = "public int moobench.benchmark.BenchmarkParameter.getTotalThreads()";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkParameter._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkParameter._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkParameter._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return totalThreads;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkParameter._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }

    public int getRecursionDepth() {
        if (!BenchmarkParameter._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            return recursionDepth;
        }
        final String _kieker_sourceInstrumentation_signature = "public int moobench.benchmark.BenchmarkParameter.getRecursionDepth()";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkParameter._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkParameter._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkParameter._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return recursionDepth;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkParameter._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }

    public File getOutputFile() {
        if (!BenchmarkParameter._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            return outputFile;
        }
        final String _kieker_sourceInstrumentation_signature = "public java.io.File moobench.benchmark.BenchmarkParameter.getOutputFile()";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkParameter._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkParameter._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkParameter._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return outputFile;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkParameter._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }

    public boolean isQuickstart() {
        if (!BenchmarkParameter._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            return quickstart;
        }
        final String _kieker_sourceInstrumentation_signature = "public boolean moobench.benchmark.BenchmarkParameter.isQuickstart()";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkParameter._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkParameter._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkParameter._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return quickstart;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkParameter._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }

    public boolean isForceTerminate() {
        if (!BenchmarkParameter._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            return forceTerminate;
        }
        final String _kieker_sourceInstrumentation_signature = "public boolean moobench.benchmark.BenchmarkParameter.isForceTerminate()";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkParameter._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkParameter._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkParameter._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return forceTerminate;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkParameter._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }

    public String getRunnableClassname() {
        if (!BenchmarkParameter._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            return runnableClassname;
        }
        final String _kieker_sourceInstrumentation_signature = "public java.lang.String moobench.benchmark.BenchmarkParameter.getRunnableClassname()";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkParameter._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkParameter._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkParameter._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return runnableClassname;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkParameter._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }

    public String getApplicationClassname() {
        if (!BenchmarkParameter._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            return applicationClassname;
        }
        final String _kieker_sourceInstrumentation_signature = "public java.lang.String moobench.benchmark.BenchmarkParameter.getApplicationClassname()";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkParameter._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkParameter._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkParameter._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return applicationClassname;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkParameter._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }

    public String getBenchmarkClassname() {
        if (!BenchmarkParameter._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            return benchmarkClassname;
        }
        final String _kieker_sourceInstrumentation_signature = "public java.lang.String moobench.benchmark.BenchmarkParameter.getBenchmarkClassname()";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkParameter._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkParameter._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkParameter._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return benchmarkClassname;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkParameter._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkParameter._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkParameter._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }
}
