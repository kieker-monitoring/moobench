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
package moobench.application;

import kieker.common.record.controlflow.OperationExecutionRecord;
import kieker.monitoring.core.controller.MonitoringController;
import kieker.monitoring.core.registry.ControlFlowRegistry;
import kieker.monitoring.core.registry.SessionRegistry;

/**
 * @author Jan Waller
 */
public final class MonitoredClassInstrumented implements MonitoredClass {

    private static final kieker.monitoring.core.controller.MonitoringController _kieker_sourceInstrumentation_controller = (MonitoringController) kieker.monitoring.core.controller.MonitoringController.getInstance();

    private static final kieker.monitoring.timer.ITimeSource _kieker_sourceInstrumentation_TIME_SOURCE = _kieker_sourceInstrumentation_controller.getTimeSource();

    private static final String _kieker_sourceInstrumentation_VM_NAME = _kieker_sourceInstrumentation_controller.getHostname();

    private static final kieker.monitoring.core.registry.SessionRegistry _kieker_sourceInstrumentation_SESSION_REGISTRY = SessionRegistry.INSTANCE;

    private static final kieker.monitoring.core.registry.ControlFlowRegistry _kieker_sourceInstrumentation_controlFlowRegistry = ControlFlowRegistry.INSTANCE;

    /**
     * Default constructor.
     */
    public MonitoredClassInstrumented() {
        if (!MonitoredClassInstrumented._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            return;
            // empty default constructor
        }
        final String _kieker_sourceInstrumentation_signature = "public new moobench.application.MonitoredClassInstrumented.<init>()";
        if (!MonitoredClassInstrumented._kieker_sourceInstrumentation_controller.isProbeActivated(_kieker_sourceInstrumentation_signature)) {
        	return;
        }
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = MonitoredClassInstrumented._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = MonitoredClassInstrumented._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            MonitoredClassInstrumented._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = MonitoredClassInstrumented._kieker_sourceInstrumentation_TIME_SOURCE.getTime();

        try {
            return;
            // empty default constructor
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = MonitoredClassInstrumented._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
         _kieker_sourceInstrumentation_controller.newOperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess);
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }

    public final long monitoredMethod(final long methodTime, final int recDepth) {
        if (!MonitoredClassInstrumented._kieker_sourceInstrumentation_controller.isMonitoringEnabled()) {
            return monitoredMethod_Extracted(methodTime, recDepth);
        }
        final String _kieker_sourceInstrumentation_signature = "public final long moobench.application.MonitoredClassInstrumented.monitoredMethod(long,int)";;
        if (!MonitoredClassInstrumented._kieker_sourceInstrumentation_controller.isProbeActivated(_kieker_sourceInstrumentation_signature)) {
        	return monitoredMethod_Extracted(methodTime, recDepth);
        }
              // collect data
      final boolean _kieker_sourceInstrumentation_entrypoint;
      final String _kieker_sourceInstrumentation_hostname = MonitoredClassInstrumented._kieker_sourceInstrumentation_VM_NAME;
      final String _kieker_sourceInstrumentation_sessionId = MonitoredClassInstrumented._kieker_sourceInstrumentation_SESSION_REGISTRY.recallThreadLocalSessionId();
      final int _kieker_sourceInstrumentation_eoi; // this is executionOrderIndex-th execution in this trace
      final int _kieker_sourceInstrumentation_ess; // this is the height in the dynamic call tree of this execution
      long _kieker_sourceInstrumentation_traceId = MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.recallThreadLocalTraceId(); // traceId, -1 if entry point
      if (_kieker_sourceInstrumentation_traceId == -1) {
         _kieker_sourceInstrumentation_entrypoint = true;
         _kieker_sourceInstrumentation_traceId = MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.getAndStoreUniqueThreadLocalTraceId();
         MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalEOI(0);
         MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(1); // next operation is ess + 1
         _kieker_sourceInstrumentation_eoi = 0;
         _kieker_sourceInstrumentation_ess = 0;
      } else {
         _kieker_sourceInstrumentation_entrypoint = false;
         _kieker_sourceInstrumentation_eoi = MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.incrementAndRecallThreadLocalEOI(); // ess > 1
         _kieker_sourceInstrumentation_ess = MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.recallAndIncrementThreadLocalESS(); // ess >= 0
         if ((_kieker_sourceInstrumentation_eoi == -1) || (_kieker_sourceInstrumentation_ess == -1)) {
            System.err.println("eoi and/or ess have invalid values: eoi == {} ess == {}"+ _kieker_sourceInstrumentation_eoi+ "" + _kieker_sourceInstrumentation_ess);
            MonitoredClassInstrumented._kieker_sourceInstrumentation_controller.terminateMonitoring();
         }
      }
      // measure before
      final long _kieker_sourceInstrumentation_tin = MonitoredClassInstrumented._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
        try {
            return monitoredMethod_Extracted(methodTime, recDepth);
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = MonitoredClassInstrumented._kieker_sourceInstrumentation_TIME_SOURCE.getTime();
//         MonitoredClassInstrumented._kieker_sourceInstrumentation_controller.newMonitoringRecord(new OperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess));
         _kieker_sourceInstrumentation_controller.newOperationExecutionRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_sessionId, _kieker_sourceInstrumentation_traceId, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout, _kieker_sourceInstrumentation_hostname, _kieker_sourceInstrumentation_eoi, _kieker_sourceInstrumentation_ess);
         // cleanup
         if (_kieker_sourceInstrumentation_entrypoint) {
            MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalTraceId();
            MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalEOI();
            MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.unsetThreadLocalESS();
         } else {
            MonitoredClassInstrumented._kieker_sourceInstrumentation_controlFlowRegistry.storeThreadLocalESS(_kieker_sourceInstrumentation_ess); // next operation is ess
         };
        }
    }

	private long monitoredMethod_Extracted(final long methodTime, final int recDepth) {
		if (recDepth > 1) {
		    return this.monitoredMethod(methodTime, recDepth - 1);
		} else {
		    final long exitTime = System.nanoTime() + methodTime;
		    long currentTime;
		    do {
		        currentTime = System.nanoTime();
		    } while (currentTime < exitTime);
		    return currentTime;
		}
	}
}
