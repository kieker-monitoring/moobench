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
import kieker.monitoring.core.registry.ControlFlowRegistry;
import kieker.monitoring.core.registry.SessionRegistry;
import kieker.monitoring.probe.disl.flow.operationExecution.KiekerMonitoringAnalysis;
import kieker.monitoring.probe.disl.flow.operationExecution.FullOperationStartData;

/**
 * @author Jan Waller
 */
public final class MonitoredClassInstrumentedDiSLStyle implements MonitoredClass {

    private static final kieker.monitoring.core.controller.IMonitoringController _kieker_sourceInstrumentation_controller = kieker.monitoring.core.controller.MonitoringController.getInstance();

    private static final kieker.monitoring.timer.ITimeSource _kieker_sourceInstrumentation_TIME_SOURCE = _kieker_sourceInstrumentation_controller.getTimeSource();

    private static final String _kieker_sourceInstrumentation_VM_NAME = _kieker_sourceInstrumentation_controller.getHostname();

    private static final kieker.monitoring.core.registry.SessionRegistry _kieker_sourceInstrumentation_SESSION_REGISTRY = SessionRegistry.INSTANCE;

    private static final kieker.monitoring.core.registry.ControlFlowRegistry _kieker_sourceInstrumentation_controlFlowRegistry = ControlFlowRegistry.INSTANCE;

    /**
     * Default constructor.
     */
    public MonitoredClassInstrumentedDiSLStyle() {
        final String _kieker_sourceInstrumentation_signature = "public new moobench.application.MonitoredClassInstrumented.<init>()";
        FullOperationStartData data = KiekerMonitoringAnalysis.operationStart(_kieker_sourceInstrumentation_signature);
        
        if (data != null) {
			KiekerMonitoringAnalysis.operationEnd(data);
		}
    }

    public final long monitoredMethod(final long methodTime, final int recDepth) {
        final String _kieker_sourceInstrumentation_signature = "public final long moobench.application.MonitoredClassInstrumented.monitoredMethod(long,int)";;
        FullOperationStartData data = KiekerMonitoringAnalysis.operationStart(_kieker_sourceInstrumentation_signature);
        try {if (recDepth > 1) {
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
        finally {
           if (data != null) {
		   	KiekerMonitoringAnalysis.operationEnd(data);
		   }
        }
        
    }
}
