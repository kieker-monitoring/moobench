/**
 * 
 */
package moobench.benchmark;

import java.io.File;

import com.beust.jcommander.Parameter;
import com.beust.jcommander.converters.FileConverter;

/**
 * @author Reiner Jung
 *
 */
public class BenchmarkParameter {
	
	@Parameter(names = { "--total-calls", "-c" }, required = true, description = "Number of total method calls performed.")
	int totalCalls;
	
	@Parameter(names = { "--method-time", "-m" }, required = true, description = "Time a method call takes.")
	int methodTime;
	
	@Parameter(names = { "--total-threads", "-t" }, required = true, description = "Number of threads started.")
	int totalThreads;
			
	@Parameter(names = { "--recursion-depth", "-d" }, required = true, description = "Depth of recursion performed.")
	int recursionDepth;

	@Parameter(names = { "--output-filename", "-o" }, required = true, converter = FileConverter.class, 
			description = "Filename of results file. Output is appended if file exists.")
	File outputFile;
	
	@Parameter(names = { "--quickstart", "-q" }, required = false, description = "Skips initial garbage collection.")
	boolean quickstart;
	
	@Parameter(names = { "--force-terminate", "-f" }, required = false, description = "Forces a termination at the end of the benchmark.")
	boolean forceTerminate;
    
	@Parameter(names = { "--runnable", "-r" }, required = false,
			description = "Class implementing the Runnable interface. run() method is executed before the benchmark starts.")
	String runnableClassname;
	
    @Parameter(names = { "--application", "-a" }, required = false, description = "Class implementing the MonitoredClass interface.")
    String applicationClassname;
    
    @Parameter(names = { "--benchmark-thread", "-b" }, required = false, description = "Class implementing the BenchmarkingThread interface.")
    String benchmarkClassname;

	public int getTotalCalls() {
		return totalCalls;
	}

	public int getMethodTime() {
		return methodTime;
	}

	public int getTotalThreads() {
		return totalThreads;
	}

	public int getRecursionDepth() {
		return recursionDepth;
	}

	public File getOutputFile() {
		return outputFile;
	}

	public boolean isQuickstart() {
		return quickstart;
	}

	public boolean isForceTerminate() {
		return forceTerminate;
	}

	public String getRunnableClassname() {
		return runnableClassname;
	}

	public String getApplicationClassname() {
		return applicationClassname;
	}

	public String getBenchmarkClassname() {
		return benchmarkClassname;
	}
    
    
    
}
