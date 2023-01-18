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
import de.dagere.kopeme.kieker.record.DurationRecord;

/**
 * @author Jan Waller
 */
public final class BenchmarkingThreadMilli implements BenchmarkingThread {

    private static final kieker.monitoring.core.controller.IMonitoringController _kieker_sourceInstrumentation_controller = kieker.monitoring.core.controller.MonitoringController.getInstance();

    private static final kieker.monitoring.timer.ITimeSource _kieker_sourceInstrumentation_TIME_SOURCE = _kieker_sourceInstrumentation_controller.getTimeSource();

    private final MonitoredClass mc;

    private final CountDownLatch doneSignal;

    private final int totalCalls;

    private final long methodTime;

    private final int recursionDepth;

    private final long[] timings;

    public BenchmarkingThreadMilli(final MonitoredClass mc, final int totalCalls, final long methodTime, final int recursionDepth, final CountDownLatch doneSignal) {
              final long _kieker_sourceInstrumentation_tin = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();;
        try {
            this.mc = mc;
            this.doneSignal = doneSignal;
            this.totalCalls = totalCalls;
            this.methodTime = methodTime;
            this.recursionDepth = recursionDepth;
            this.timings = new long[totalCalls];
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
        _kieker_sourceInstrumentation_initSum0+=_kieker_sourceInstrumentation_tout-_kieker_sourceInstrumentation_tin;
if (_kieker_sourceInstrumentation_initCounter0++%1000==0){
final String _kieker_sourceInstrumentation_signature = "public new moobench.benchmark.BenchmarkingThreadMilli.<init>(moobench.application.MonitoredClass,int,long,int,java.util.concurrent.CountDownLatch)";
final long _kieker_sourceInstrumentation_calculatedTout=_kieker_sourceInstrumentation_tin+_kieker_sourceInstrumentation_initSum0;
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_calculatedTout));
_kieker_sourceInstrumentation_initSum0=0;}
;
        }
    }

    public final long[] getTimings() {
              final long _kieker_sourceInstrumentation_tin = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();;
        try {
            synchronized (this) {
                return this.timings;
            }
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
        _kieker_sourceInstrumentation_getTimingsSum1+=_kieker_sourceInstrumentation_tout-_kieker_sourceInstrumentation_tin;
if (_kieker_sourceInstrumentation_getTimingsCounter1++%1000==0){
final String _kieker_sourceInstrumentation_signature = "public final long[] moobench.benchmark.BenchmarkingThreadMilli.getTimings()";
final long _kieker_sourceInstrumentation_calculatedTout=_kieker_sourceInstrumentation_tin+_kieker_sourceInstrumentation_getTimingsSum1;
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_calculatedTout));
_kieker_sourceInstrumentation_getTimingsSum1=0;}
;
        }
    }

    public String print(final int index, final String separatorString) {
              final long _kieker_sourceInstrumentation_tin = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();;
        try {
            return "" + this.timings[index];
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
        _kieker_sourceInstrumentation_printSum2+=_kieker_sourceInstrumentation_tout-_kieker_sourceInstrumentation_tin;
if (_kieker_sourceInstrumentation_printCounter2++%1000==0){
final String _kieker_sourceInstrumentation_signature = "public java.lang.String moobench.benchmark.BenchmarkingThreadMilli.print(int,java.lang.String)";
final long _kieker_sourceInstrumentation_calculatedTout=_kieker_sourceInstrumentation_tin+_kieker_sourceInstrumentation_printSum2;
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_calculatedTout));
_kieker_sourceInstrumentation_printSum2=0;}
;
        }
    }

    public final void run() {
              final long _kieker_sourceInstrumentation_tin = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();;
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
        } finally {
            // measure after
         final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
        _kieker_sourceInstrumentation_runSum3+=_kieker_sourceInstrumentation_tout-_kieker_sourceInstrumentation_tin;
if (_kieker_sourceInstrumentation_runCounter3++%1000==0){
final String _kieker_sourceInstrumentation_signature = "public final void moobench.benchmark.BenchmarkingThreadMilli.run()";
final long _kieker_sourceInstrumentation_calculatedTout=_kieker_sourceInstrumentation_tin+_kieker_sourceInstrumentation_runSum3;
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_calculatedTout));
_kieker_sourceInstrumentation_runSum3=0;}
;
        }
    }

    private static int _kieker_sourceInstrumentation_initCounter0;

    private static int _kieker_sourceInstrumentation_getTimingsCounter1;

    private static int _kieker_sourceInstrumentation_printCounter2;

    private static int _kieker_sourceInstrumentation_runCounter3;

    private static long _kieker_sourceInstrumentation_initSum0;

    private static long _kieker_sourceInstrumentation_getTimingsSum1;

    private static long _kieker_sourceInstrumentation_printSum2;

    private static long _kieker_sourceInstrumentation_runSum3;
}
