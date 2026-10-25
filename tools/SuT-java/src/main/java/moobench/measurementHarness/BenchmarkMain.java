/***************************************************************************
 * Copyright 2014 Kieker Project (http://kieker-monitoring.net)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ***************************************************************************/

package moobench.measurementHarness;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.ParameterException;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.PrintStream;
import java.nio.file.Files;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import moobench.application.MonitoredClass;
import moobench.application.MonitoredClassThreaded;
import java.nio.file.Path;
import java.nio.file.Paths;



/**
 * @author Jan Waller
 */
public final class BenchmarkMain {
    private static final String ENCODING = "UTF-8";
    
    private static final Path rapl_path = Paths.get("/sys/class/powercap/intel-rapl:0/energy_uj");

    private static PrintStream ps = null;
    
    private static PrintStream es = null;

    private static BenchmarkParameter parameter = new BenchmarkParameter();

    private static MonitoredClass monitoredClass;

    private BenchmarkMain() {
    }

    public static void main(final String[] args) throws InterruptedException, IOException {
    	


        // 1. Preparations
        BenchmarkMain.parseAndInitializeArguments(args);

        System.out.println(" # Experiment run configuration:"); // NOPMD (System.out)
        System.out.println(" # 1. Output filename " + parameter.getOutputFile().toPath().toString()); // NOPMD (System.out)
        System.out.println(" # 2. Recursion Depth " + parameter.getRecursionDepth()); // NOPMD (System.out)
        System.out.println(" # 3. Threads " + parameter.getTotalThreads()); // NOPMD (System.out)
        System.out.println(" # 4. Total-Calls " + parameter.getTotalCalls()); // NOPMD (System.out)
        System.out.println(" # 5. Method-Time " + parameter.getMethodTime()); // NOPMD (System.out)

        long freeA = getFreeDiskSpaceKb();
        // 2. Initialize Threads and Classes
        BenchmarkingThreadEnergy pkg = null;
        long cpu_energy_start = 0L;
        long cpu_energy_end = 0L;
        
        
        final CountDownLatch doneSignal = new CountDownLatch(parameter.getTotalThreads());
        final BenchmarkingThread[] benchmarkingThreads = new BenchmarkingThread[parameter.getTotalThreads()];
        final Thread[] threads = new Thread[parameter.getTotalThreads()];
        for (int i = 0; i < parameter.getTotalThreads(); i++) {
            benchmarkingThreads[i] = new BenchmarkingThreadNano(BenchmarkMain.monitoredClass, parameter.getTotalCalls(),
                    parameter.getMethodTime(), parameter.getRecursionDepth(), doneSignal);
            threads[i] = new Thread(benchmarkingThreads[i], String.valueOf(i + 1));
        }
        if (!parameter.isQuickstart()) {
            for (int l = 0; l < 4; l++) {
                { // NOCS (reserve mem only within the block)
                    final long freeMemChunks = Runtime.getRuntime().freeMemory() >> 27;
            // System.out.println("Free-Mem: " + Runtime.getRuntime().freeMemory());
            final int memSize = 128 * 1024 * 128; // memSize * 8 = total Bytes -> 128MB
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
        
        
        
        if (parameter.getEnergyStatus()) {
        	pkg = new BenchmarkingThreadEnergy(rapl_path);
        	cpu_energy_start = pkg.read_rapl();}
        
        
        final long startTime = System.currentTimeMillis();
        System.out.println(" # 6. Starting benchmark ..."); // NOPMD (System.out)
        // 3. Starting Threads
        for (int i = 0; i < parameter.getTotalThreads(); i++) {
            threads[i].start();
        }

        // 4. Wait for all Threads
        try {
            doneSignal.await();
        } catch (final InterruptedException e) {
            e.printStackTrace(); // NOPMD (Stacktrace)
            System.exit(-1);
        }
        final long totalTime = System.currentTimeMillis() - startTime;
        
        if (parameter.getEnergyStatus()) {
       cpu_energy_end = pkg.read_rapl();}
        
        
        System.out.println(" #    done (" + TimeUnit.MILLISECONDS.toSeconds(totalTime) + " s)"); // NOPMD
      
        
        
        // 5. Print experiment statistics
        System.out.print(" # 7. Writing results ... "); // NOPMD (System.out)
        // CSV Format: configuration;order_index;Thread-ID;duration_nsec
        for (int h = 0; h < parameter.getTotalThreads(); h++) {
            final BenchmarkingThread thread = benchmarkingThreads[h];
            for (int i = 0; i < parameter.getTotalCalls(); i++) {
                final String line = threads[h].getName() + ";" + thread.print(i, ";");
                BenchmarkMain.ps.println(line);
            }
        }
        BenchmarkMain.ps.close();
        
        BenchmarkMain.es.println("start_uj;end_uj;");
        BenchmarkMain.es.println(cpu_energy_start + ";" + cpu_energy_end);
        BenchmarkMain.es.close();
        

        System.out.println("done"); // NOPMD (System.out)
        System.out.println(" # "); // NOPMD (System.out)

        long freeB = getFreeDiskSpaceKb();
        System.out.println("Disk usage: " + (freeA - freeB) + " kB");
        
        if (parameter.isForceTerminate()) {
            System.exit(0);
        }
        
    }
    
    public static long getFreeDiskSpaceKb() {
      File f = new File(".");
      return f.getFreeSpace() / 1024;
    }

    public static void parseAndInitializeArguments(final String[] argv) {
        JCommander commander = null;
        try {
            commander = JCommander.newBuilder().addObject(parameter).build();
            commander.parse(argv);

            BenchmarkMain.ps = new PrintStream(
                    new BufferedOutputStream(Files.newOutputStream(parameter.getOutputFile().toPath()), 8192 * 8),
                    false, BenchmarkMain.ENCODING);
            
            BenchmarkMain.es = new PrintStream(
                    new BufferedOutputStream(Files.newOutputStream(parameter.getEnergyFile().toPath()), 8192 * 8),
                    false, BenchmarkMain.ENCODING);
            
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
        } catch (final Exception ex) { // NOCS (e.g., IOException, ParseException,
            // NumberFormatException)
            if (commander != null) {
                commander.usage();
            }
            System.out.println(ex.toString()); // NOPMD (Stacktrace)
            ex.printStackTrace();
            System.exit(-1);
        }
    }
}
