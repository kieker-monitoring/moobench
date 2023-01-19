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
package moobench.application.sourceInstrumentation;

import java.lang.management.ManagementFactory;
import java.lang.management.ThreadMXBean;

import moobench.application.MonitoredClass;
import de.dagere.kopeme.kieker.record.DurationRecord;

/**
 * @author Jan Waller
 */
public final class MonitoredClassThreaded implements MonitoredClass {

    private static final kieker.monitoring.core.controller.IMonitoringController _kieker_sourceInstrumentation_controller = kieker.monitoring.core.controller.MonitoringController.getInstance();

    private static final kieker.monitoring.timer.ITimeSource _kieker_sourceInstrumentation_TIME_SOURCE = _kieker_sourceInstrumentation_controller.getTimeSource();

    final ThreadMXBean threadMXBean = ManagementFactory.getThreadMXBean();

    /**
     * Default constructor.
     */
    public MonitoredClassThreaded() {
        final String _kieker_sourceInstrumentation_signature = "public new moobench.application.MonitoredClassThreaded.<init>()";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            // empty default constructor
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }

    @Override
	public final long monitoredMethod(final long methodTime, final int recDepth) {
        final String _kieker_sourceInstrumentation_signature = "public final long moobench.application.MonitoredClassThreaded.monitoredMethod(long,int)";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            if (recDepth > 1) {
                return this.monitoredMethod(methodTime, recDepth - 1);
            } else {
                final long exitTime = this.threadMXBean.getCurrentThreadUserTime() + methodTime;
                long currentTime;
                do {
                    currentTime = this.threadMXBean.getCurrentThreadUserTime();
                } while (currentTime < exitTime);
                return currentTime;
            }
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }
}
