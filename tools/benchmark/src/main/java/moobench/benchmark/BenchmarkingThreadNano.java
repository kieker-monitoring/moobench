/**
 * ************************************************************************
 *  Copyright 2014 Kieker Project (http://kieker-monitoring.net)
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 * *************************************************************************
 */
package moobench.benchmark;

import java.lang.management.GarbageCollectorMXBean;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryMXBean;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import moobench.application.MonitoredClass;
import kieker.monitoring.core.controller.MonitoringController;
import kieker.monitoring.core.registry.ControlFlowRegistry;
import kieker.monitoring.core.registry.SessionRegistry;
import kieker.common.record.controlflow.OperationExecutionRecord;

/**
 * @author Jan Waller, Aike Sass, Christian Wulf
 */
public final class BenchmarkingThreadNano implements BenchmarkingThread {

    private static final kieker.monitoring.core.controller.IMonitoringController _kieker_sourceInstrumentation_controller = kieker.monitoring.core.controller.MonitoringController.getInstance();

    private static final kieker.monitoring.timer.ITimeSource _kieker_sourceInstrumentation_TIME_SOURCE = _kieker_sourceInstrumentation_controller.getTimeSource();

    private static final String _kieker_sourceInstrumentation_VM_NAME = _kieker_sourceInstrumentation_controller.getHostname();

    private static final kieker.monitoring.core.registry.SessionRegistry _kieker_sourceInstrumentation_SESSION_REGISTRY = SessionRegistry.INSTANCE;

    private static final kieker.monitoring.core.registry.ControlFlowRegistry _kieker_sourceInstrumentation_controlFlowRegistry = ControlFlowRegistry.INSTANCE;

    private final MonitoredClass mc;

    private final CountDownLatch doneSignal;

    private final int totalCalls;

    private final long methodTime;

    private final int recursionDepth;

    private final long[] executionTimes;

    private final MemoryMXBean memory;

    private final long[] usedHeapMemory;

    private final long[] gcCollectionCountDiffs;

    private final List<GarbageCollectorMXBean> collector;

    public BenchmarkingThreadNano(final MonitoredClass mc, final int totalCalls, final long methodTime, final int recursionDepth, final CountDownLatch doneSignal) {
        if (!BenchmarkingThreadNano._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            this.mc = mc;
            this.doneSignal = doneSignal;
            this.totalCalls = totalCalls;
            this.methodTime = methodTime;
            this.recursionDepth = recursionDepth;
            // for monitoring execution times
            this.executionTimes = new long[totalCalls];
            // for monitoring memory consumption
            this.memory = ManagementFactory.getMemoryMXBean();
            this.usedHeapMemory = new long[totalCalls];
            // for monitoring the garbage collector
            this.gcCollectionCountDiffs = new long[totalCalls];
            this.collector = ManagementFactory.getGarbageCollectorMXBeans();
            return;
        }
        final String _kieker_sourceInstrumentation_signature = "public new moobench.benchmark.BenchmarkingThreadNano.<init>(moobench.application.MonitoredClass,int,long,int,java.util.concurrent.CountDownLatch)";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkingThreadNano._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkingThreadNano._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkingThreadNano._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            this.mc = mc;
            this.doneSignal = doneSignal;
            this.totalCalls = totalCalls;
            this.methodTime = methodTime;
            this.recursionDepth = recursionDepth;
            // for monitoring execution times
            this.executionTimes = new long[totalCalls];
            // for monitoring memory consumption
            this.memory = ManagementFactory.getMemoryMXBean();
            this.usedHeapMemory = new long[totalCalls];
            // for monitoring the garbage collector
            this.gcCollectionCountDiffs = new long[totalCalls];
            this.collector = ManagementFactory.getGarbageCollectorMXBeans();
            return;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkingThreadNano._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkingThreadNano._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }

    public String print(final int index, final String separatorString) {
        if (!BenchmarkingThreadNano._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            return String.format("%d%s%d%s%d", this.executionTimes[index], separatorString, this.usedHeapMemory[index], separatorString, this.gcCollectionCountDiffs[index]);
        }
        final String _kieker_sourceInstrumentation_signature = "public java.lang.String moobench.benchmark.BenchmarkingThreadNano.print(int,java.lang.String)";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkingThreadNano._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkingThreadNano._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkingThreadNano._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return String.format("%d%s%d%s%d", this.executionTimes[index], separatorString, this.usedHeapMemory[index], separatorString, this.gcCollectionCountDiffs[index]);
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkingThreadNano._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkingThreadNano._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }

    public final void run() {
        if (!BenchmarkingThreadNano._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            long start_ns;
            long stop_ns;
            long lastGcCount = this.computeGcCollectionCount();
            long currentGcCount;
            for (int i = 0; i < this.totalCalls; i++) {
                start_ns = this.getCurrentTimestamp();
                this.mc.monitoredMethod(this.methodTime, this.recursionDepth);
                stop_ns = this.getCurrentTimestamp();
                currentGcCount = this.computeGcCollectionCount();
                // save execution time
                this.executionTimes[i] = stop_ns - start_ns;
                // save heap memory
                this.usedHeapMemory[i] = this.memory.getHeapMemoryUsage().getUsed();
                // save gc collection count
                this.gcCollectionCountDiffs[i] = currentGcCount - lastGcCount;
                lastGcCount = currentGcCount;
                // print progress
                if ((i % 100000) == 0) {
                    // NOPMD (System.out)
                    System.out.println(i);
                }
            }
            this.doneSignal.countDown();
            return;
        }
        final String _kieker_sourceInstrumentation_signature = "public final void moobench.benchmark.BenchmarkingThreadNano.run()";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkingThreadNano._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkingThreadNano._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkingThreadNano._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            long start_ns;
            long stop_ns;
            long lastGcCount = this.computeGcCollectionCount();
            long currentGcCount;
            for (int i = 0; i < this.totalCalls; i++) {
                start_ns = this.getCurrentTimestamp();
                this.mc.monitoredMethod(this.methodTime, this.recursionDepth);
                stop_ns = this.getCurrentTimestamp();
                currentGcCount = this.computeGcCollectionCount();
                // save execution time
                this.executionTimes[i] = stop_ns - start_ns;
                // save heap memory
                this.usedHeapMemory[i] = this.memory.getHeapMemoryUsage().getUsed();
                // save gc collection count
                this.gcCollectionCountDiffs[i] = currentGcCount - lastGcCount;
                lastGcCount = currentGcCount;
                // print progress
                if ((i % 100000) == 0) {
                    // NOPMD (System.out)
                    System.out.println(i);
                }
            }
            this.doneSignal.countDown();
            return;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkingThreadNano._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkingThreadNano._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }

    private long computeGcCollectionCount() {
        if (!BenchmarkingThreadNano._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            long count = 0;
            for (final GarbageCollectorMXBean bean : this.collector) {
                count += bean.getCollectionCount();
                // bean.getCollectionTime()
            }
            return count;
        }
        final String _kieker_sourceInstrumentation_signature = "private long moobench.benchmark.BenchmarkingThreadNano.computeGcCollectionCount()";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkingThreadNano._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkingThreadNano._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkingThreadNano._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            long count = 0;
            for (final GarbageCollectorMXBean bean : this.collector) {
                count += bean.getCollectionCount();
                // bean.getCollectionTime()
            }
            return count;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkingThreadNano._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkingThreadNano._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }

    private long getCurrentTimestamp() {
        if (!BenchmarkingThreadNano._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            // alternatively: System.currentTimeMillis();
            return System.nanoTime();
        }
        final String _kieker_sourceInstrumentation_signature = "private long moobench.benchmark.BenchmarkingThreadNano.getCurrentTimestamp()";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkingThreadNano._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkingThreadNano._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkingThreadNano._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            // alternatively: System.currentTimeMillis();
            return System.nanoTime();
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkingThreadNano._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkingThreadNano._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkingThreadNano._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }
}
