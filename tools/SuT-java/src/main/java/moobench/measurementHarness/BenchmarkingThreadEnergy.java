package moobench.measurementHarness;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;

public class BenchmarkingThreadEnergy implements AutoCloseable{

	private final FileChannel channel;
    private final ByteBuffer buffer;
    
    
    public BenchmarkingThreadEnergy(final Path energy_path) throws IOException{
    	this.channel = FileChannel.open(energy_path, StandardOpenOption.READ);
    	 this.buffer = ByteBuffer.allocate(32);
    }
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
	
	@Override
    public void close() throws IOException {
		channel.close();
	}
	
	

}
