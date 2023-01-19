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
package moobench.application.aggregated;

import moobench.application.MonitoredClass;
import de.dagere.kopeme.kieker.record.DurationRecord;

/**
 * @author Jan Waller
 */
public final class MonitoredClassSimple implements MonitoredClass {

    private static final kieker.monitoring.core.controller.IMonitoringController _kieker_sourceInstrumentation_controller = kieker.monitoring.core.controller.MonitoringController.getInstance();

    private static final kieker.monitoring.timer.ITimeSource _kieker_sourceInstrumentation_TIME_SOURCE = _kieker_sourceInstrumentation_controller.getTimeSource();

    /**
     * Default constructor.
     */
    public MonitoredClassSimple() {
              final long _kieker_sourceInstrumentation_tin = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();;
        try {
            // empty default constructor
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
        _kieker_sourceInstrumentation_initSum0+=_kieker_sourceInstrumentation_tout-_kieker_sourceInstrumentation_tin;
if (_kieker_sourceInstrumentation_initCounter0++%1000==0){
final String _kieker_sourceInstrumentation_signature = "public new moobench.application.MonitoredClassSimple.<init>()";
final long _kieker_sourceInstrumentation_calculatedTout=_kieker_sourceInstrumentation_tin+_kieker_sourceInstrumentation_initSum0;
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_calculatedTout));
_kieker_sourceInstrumentation_initSum0=0;}
;
        }
    }

    @Override
	public final long monitoredMethod(final long methodTime, final int recDepth) {
              final long _kieker_sourceInstrumentation_tin = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();;
        try {
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
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
        _kieker_sourceInstrumentation_monitoredMethodSum1+=_kieker_sourceInstrumentation_tout-_kieker_sourceInstrumentation_tin;
if (_kieker_sourceInstrumentation_monitoredMethodCounter1++%1000==0){
final String _kieker_sourceInstrumentation_signature = "public final long moobench.application.MonitoredClassSimple.monitoredMethod(long,int)";
final long _kieker_sourceInstrumentation_calculatedTout=_kieker_sourceInstrumentation_tin+_kieker_sourceInstrumentation_monitoredMethodSum1;
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_calculatedTout));
_kieker_sourceInstrumentation_monitoredMethodSum1=0;}
;
        }
    }

    private static int _kieker_sourceInstrumentation_initCounter0;

    private static int _kieker_sourceInstrumentation_monitoredMethodCounter1;

    private static long _kieker_sourceInstrumentation_initSum0;

    private static long _kieker_sourceInstrumentation_monitoredMethodSum1;
}