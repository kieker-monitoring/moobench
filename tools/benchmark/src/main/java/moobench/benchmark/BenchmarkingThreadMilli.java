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

import java.util.concurrent.CountDownLatch;
import moobench.application.MonitoredClass;
import kieker.monitoring.core.controller.MonitoringController;
import kieker.monitoring.core.registry.ControlFlowRegistry;
import kieker.monitoring.core.registry.SessionRegistry;
import kieker.common.record.controlflow.OperationExecutionRecord;

/**
 * @author Jan Waller
 */
public final class BenchmarkingThreadMilli implements BenchmarkingThread {

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

    private final long[] timings;

    public BenchmarkingThreadMilli(final MonitoredClass mc, final int totalCalls, final long methodTime, final int recursionDepth, final CountDownLatch doneSignal) {
        if (!BenchmarkingThreadMilli._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            this.mc = mc;
            this.doneSignal = doneSignal;
            this.totalCalls = totalCalls;
            this.methodTime = methodTime;
            this.recursionDepth = recursionDepth;
            this.timings = new long[totalCalls];
            return;
        }
        final String _kieker_sourceInstrumentation_signature = "public new moobench.benchmark.BenchmarkingThreadMilli.<init>(moobench.application.MonitoredClass,int,long,int,java.util.concurrent.CountDownLatch)";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkingThreadMilli._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkingThreadMilli._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkingThreadMilli._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            this.mc = mc;
            this.doneSignal = doneSignal;
            this.totalCalls = totalCalls;
            this.methodTime = methodTime;
            this.recursionDepth = recursionDepth;
            this.timings = new long[totalCalls];
            return;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkingThreadMilli._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkingThreadMilli._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }

    public final long[] getTimings() {
        if (!BenchmarkingThreadMilli._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            synchronized (this) {
                return this.timings;
            }
        }
        final String _kieker_sourceInstrumentation_signature = "public final long[] moobench.benchmark.BenchmarkingThreadMilli.getTimings()";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkingThreadMilli._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkingThreadMilli._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkingThreadMilli._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            synchronized (this) {
                return this.timings;
            }
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkingThreadMilli._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkingThreadMilli._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }

    public String print(final int index, final String separatorString) {
        if (!BenchmarkingThreadMilli._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            return "" + this.timings[index];
        }
        final String _kieker_sourceInstrumentation_signature = "public java.lang.String moobench.benchmark.BenchmarkingThreadMilli.print(int,java.lang.String)";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkingThreadMilli._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkingThreadMilli._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkingThreadMilli._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return "" + this.timings[index];
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkingThreadMilli._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkingThreadMilli._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }

    public final void run() {
        if (!BenchmarkingThreadMilli._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            long start_ns;
            long stop_ns;
            for (int i = 0; i < this.totalCalls; i++) {
                start_ns = System.currentTimeMillis();
                this.mc.monitoredMethod(this.methodTime, this.recursionDepth);
                stop_ns = System.currentTimeMillis();
                this.timings[i] = stop_ns - start_ns;
                if ((i % 100000) == 0) {
                    // NOPMD (System.out)
                    System.out.println(i);
                }
            }
            this.doneSignal.countDown();
            return;
        }
        final String _kieker_sourceInstrumentation_signature = "public final void moobench.benchmark.BenchmarkingThreadMilli.run()";;
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = BenchmarkingThreadMilli._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = BenchmarkingThreadMilli._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = BenchmarkingThreadMilli._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            long start_ns;
            long stop_ns;
            for (int i = 0; i < this.totalCalls; i++) {
                start_ns = System.currentTimeMillis();
                this.mc.monitoredMethod(this.methodTime, this.recursionDepth);
                stop_ns = System.currentTimeMillis();
                this.timings[i] = stop_ns - start_ns;
                if ((i % 100000) == 0) {
                    // NOPMD (System.out)
                    System.out.println(i);
                }
            }
            this.doneSignal.countDown();
            return;
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = BenchmarkingThreadMilli._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         BenchmarkingThreadMilli._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            BenchmarkingThreadMilli._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }
}
