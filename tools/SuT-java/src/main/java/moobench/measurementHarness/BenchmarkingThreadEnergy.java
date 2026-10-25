package moobench.measurementHarness;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
/**
 * @author Mohamed Khaled
 *
 */
// This creates the energy reading class 
public class BenchmarkingThreadEnergy implements AutoCloseable{

	private final FileChannel channel;
    private final ByteBuffer buffer;
    
    //This function opens the file and keeps it open and takes the file path as input
    public BenchmarkingThreadEnergy(final Path energy_path) throws IOException{
    	this.channel = FileChannel.open(energy_path, StandardOpenOption.READ);
    	 this.buffer = ByteBuffer.allocate(32);
    }
    
    // This function parses the RAPL readings and returns a long 
	public long read_rapl() throws IOException{
		buffer.clear();
	    final int bytesRead = channel.read(buffer, 0);

	    long value = 0;
	    for (int i = 0; i < bytesRead; i++) {
	        final byte b = buffer.get(i);
	        if (b < '0' || b > '9') {
	            break; 
	        }
	        value = value * 10 + (b - '0');
	    }
	    return value;
		
	}
	
	//this function is used to close the open file
	@Override
    public void close() throws IOException {
		channel.close();
	}
	
	

}
