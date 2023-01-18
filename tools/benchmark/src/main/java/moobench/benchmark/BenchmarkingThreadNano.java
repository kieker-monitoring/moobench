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
import de.dagere.kopeme.kieker.record.DurationRecord;

/**
 * @author Jan Waller, Aike Sass, Christian Wulf
 */
public final class BenchmarkingThreadNano implements BenchmarkingThread {

    private static final kieker.monitoring.core.controller.IMonitoringController _kieker_sourceInstrumentation_controller = kieker.monitoring.core.controller.MonitoringController.getInstance();

    private static final kieker.monitoring.timer.ITimeSource _kieker_sourceInstrumentation_TIME_SOURCE = _kieker_sourceInstrumentation_controller.getTimeSource();

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
        final String _kieker_sourceInstrumentation_signature = "public new moobench.benchmark.BenchmarkingThreadNano.<init>(moobench.application.MonitoredClass,int,long,int,java.util.concurrent.CountDownLatch)";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
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
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }

    public String print(final int index, final String separatorString) {
        final String _kieker_sourceInstrumentation_signature = "public java.lang.String moobench.benchmark.BenchmarkingThreadNano.print(int,java.lang.String)";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            return String.format("%d%s%d%s%d", this.executionTimes[index], separatorString, this.usedHeapMemory[index], separatorString, this.gcCollectionCountDiffs[index]);
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }

    public final void run() {
        final String _kieker_sourceInstrumentation_signature = "public final void moobench.benchmark.BenchmarkingThreadNano.run()";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
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
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }

    private long computeGcCollectionCount() {
        final String _kieker_sourceInstrumentation_signature = "private long moobench.benchmark.BenchmarkingThreadNano.computeGcCollectionCount()";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
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
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }

    private long getCurrentTimestamp() {
        final String _kieker_sourceInstrumentation_signature = "private long moobench.benchmark.BenchmarkingThreadNano.getCurrentTimestamp()";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            // alternatively: System.currentTimeMillis();
            return System.nanoTime();
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }
}
