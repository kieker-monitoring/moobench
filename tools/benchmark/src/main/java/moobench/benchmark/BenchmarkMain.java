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

import java.io.BufferedOutputStream;
import java.io.PrintStream;
import java.nio.file.Files;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import com.beust.jcommander.JCommander;
import com.beust.jcommander.ParameterException;
import moobench.application.MonitoredClass;
import moobench.application.MonitoredClassThreaded;
import kieker.monitoring.core.controller.MonitoringController;
import kieker.monitoring.core.registry.ControlFlowRegistry;
import kieker.monitoring.core.registry.SessionRegistry;
import de.dagere.kopeme.kieker.record.DurationRecord;

/**
 * @author Jan Waller
 */
public final class BenchmarkMain {

    private static final kieker.monitoring.core.controller.IMonitoringController _kieker_sourceInstrumentation_controller = kieker.monitoring.core.controller.MonitoringController.getInstance();

    private static final kieker.monitoring.timer.ITimeSource _kieker_sourceInstrumentation_TIME_SOURCE = _kieker_sourceInstrumentation_controller.getTimeSource();

    private static final String ENCODING = "UTF-8";

    private static PrintStream ps = null;

    private static BenchmarkParameter parameter = new BenchmarkParameter();

    private static MonitoredClass monitoredClass;

    private BenchmarkMain() {
        final String _kieker_sourceInstrumentation_signature = "private new moobench.benchmark.BenchmarkMain.<init>()";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }

    public static void main(final String[] args) throws InterruptedException {
        final String _kieker_sourceInstrumentation_signature = "public static void moobench.benchmark.BenchmarkMain.main(java.lang.String[])";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            // 1. Preparations
            BenchmarkMain.parseAndInitializeArguments(args);
            // NOPMD (System.out)
            System.out.println(" # Experiment run configuration:");
            // NOPMD (System.out)
            System.out.println(" # 1. Output filename " + parameter.getOutputFile().toPath().toString());
            // NOPMD (System.out)
            System.out.println(" # 2. Recursion Depth " + parameter.getRecursionDepth());
            // NOPMD (System.out)
            System.out.println(" # 3. Threads " + parameter.getTotalThreads());
            // NOPMD (System.out)
            System.out.println(" # 4. Total-Calls " + parameter.getTotalCalls());
            // NOPMD (System.out)
            System.out.println(" # 5. Method-Time " + parameter.getMethodTime());
            // 2. Initialize Threads and Classes
            final CountDownLatch doneSignal = new CountDownLatch(parameter.getTotalThreads());
            final BenchmarkingThread[] benchmarkingThreads = new BenchmarkingThread[parameter.getTotalThreads()];
            final Thread[] threads = new Thread[parameter.getTotalThreads()];
            for (int i = 0; i < parameter.getTotalThreads(); i++) {
                benchmarkingThreads[i] = new BenchmarkingThreadNano(BenchmarkMain.monitoredClass, parameter.getTotalCalls(), parameter.getMethodTime(), parameter.getRecursionDepth(), doneSignal);
                threads[i] = new Thread(benchmarkingThreads[i], String.valueOf(i + 1));
            }
            if (!parameter.isQuickstart()) {
                for (int l = 0; l < 4; l++) {
                    {
                        // NOCS (reserve mem only within the block)
                        final long freeMemChunks = Runtime.getRuntime().freeMemory() >> 27;
                        // System.out.println("Free-Mem: " + Runtime.getRuntime().freeMemory());
                        // memSize * 8 = total Bytes -> 128MB
                        final int memSize = 128 * 1024 * 128;
                        for (int j = 0; j < freeMemChunks; j++) {
                            final long[] grabMemory = new long[memSize];
                            for (int i = 0; i < memSize; i++) {
                                grabMemory[i] = System.nanoTime();
                            }
                        }
                        // System.out.println("done grabbing memory...");
                        // System.out.println("Free-Mem: " + Runtime.getRuntime().freeMemory());
                    }
                    Thread.sleep(5000);
                }
            }
            final long startTime = System.currentTimeMillis();
            // NOPMD (System.out)
            System.out.println(" # 6. Starting benchmark ...");
            // 3. Starting Threads
            for (int i = 0; i < parameter.getTotalThreads(); i++) {
                threads[i].start();
            }
            // 4. Wait for all Threads
            try {
                doneSignal.await();
            } catch (final InterruptedException e) {
                // NOPMD (Stacktrace)
                e.printStackTrace();
                System.exit(-1);
            }
            final long totalTime = System.currentTimeMillis() - startTime;
            // NOPMD
            System.out.println(" #    done (" + TimeUnit.MILLISECONDS.toSeconds(totalTime) + " s)");
            // (System.out)
            // 5. Print experiment statistics
            // NOPMD (System.out)
            System.out.print(" # 7. Writing results ... ");
            // CSV Format: configuration;order_index;Thread-ID;duration_nsec
            for (int h = 0; h < parameter.getTotalThreads(); h++) {
                final BenchmarkingThread thread = benchmarkingThreads[h];
                for (int i = 0; i < parameter.getTotalCalls(); i++) {
                    final String line = threads[h].getName() + ";" + thread.print(i, ";");
                    BenchmarkMain.ps.println(line);
                }
            }
            BenchmarkMain.ps.close();
            // NOPMD (System.out)
            System.out.println("done");
            // NOPMD (System.out)
            System.out.println(" # ");
            if (parameter.isForceTerminate()) {
                System.exit(0);
            }
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }

    public static void parseAndInitializeArguments(final String[] argv) {
        final String _kieker_sourceInstrumentation_signature = "public static void moobench.benchmark.BenchmarkMain.parseAndInitializeArguments(java.lang.String[])";;
              final long _kieker_sourceInstrumentation_tin =_kieker_sourceInstrumentation_TIME_SOURCE.getTime();
;
        try {
            JCommander commander = null;
            try {
                commander = JCommander.newBuilder().addObject(parameter).build();
                commander.parse(argv);
                BenchmarkMain.ps = new PrintStream(new BufferedOutputStream(Files.newOutputStream(parameter.getOutputFile().toPath()), 8192 * 8), false, BenchmarkMain.ENCODING);
                if (null != parameter.getApplicationClassname()) {
                    monitoredClass = (MonitoredClass) Class.forName(parameter.getApplicationClassname()).getDeclaredConstructor().newInstance();
                } else {
                    monitoredClass = new MonitoredClassThreaded();
                }
                if (null != parameter.getRunnableClassname()) {
                    ((Runnable) Class.forName(parameter.getRunnableClassname()).getDeclaredConstructor().newInstance()).run();
                }
            } catch (final ParameterException ex) {
                if (commander != null) {
                    commander.usage();
                }
                System.out.println(ex.getLocalizedMessage());
                System.exit(-1);
            } catch (final Exception ex) {
                // NOCS (e.g., IOException, ParseException,
                // NumberFormatException)
                if (commander != null) {
                    commander.usage();
                }
                // NOPMD (Stacktrace)
                System.out.println(ex.toString());
                ex.printStackTrace();
                System.exit(-1);
            }
        } finally {
            // measure after
final long _kieker_sourceInstrumentation_tout = _kieker_sourceInstrumentation_TIME_SOURCE.getTime();
_kieker_sourceInstrumentation_controller.newMonitoringRecord(new DurationRecord(_kieker_sourceInstrumentation_signature, _kieker_sourceInstrumentation_tin, _kieker_sourceInstrumentation_tout));
        }
    }
}
