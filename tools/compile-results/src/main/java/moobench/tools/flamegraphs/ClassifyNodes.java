package moobench.tools.flamegraphs;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;



public class ClassifyNodes {
	
	public static void main(String[] args) throws FileNotFoundException, IOException {
		System.out.println("Starting");

		for (String fileName : args) {
			File file = new File(fileName);
			if (!file.exists()) {
				System.out.println("File does not exist: " + file);
			} else {
				System.out.println("Reading " + file);
				CallTreeNode root;
				try (InputStream in = new FileInputStream(file)) {
					root = parseCollapsedStacks(in);
				}
				
				CallTreeNode mainThread = root
						.getOrCreateChild("java.lang.Thread", "run")
						.getOrCreateChild("java.lang.Thread", "runWith")
						.getOrCreateChild("moobench.benchmark.BenchmarkingThreadNano", "run")
						.getOrCreateChild("moobench.application.MonitoredClassSimple", "monitoredMethod");
				
				new FindMappings().searchKnownMethods(mainThread);
				
//				printTree(root, "");
			}
		}
	}

	

	public static CallTreeNode parseCollapsedStacks(InputStream in) throws IOException {
		CallTreeNode root = new CallTreeNode(null, "<root>", "<root>");
		try (BufferedReader reader = new BufferedReader(new InputStreamReader(in))) {
			String line;
			while ((line = reader.readLine()) != null) {
				if (line.isBlank())
					continue;
				int lastSpace = line.lastIndexOf(' ');
				if (lastSpace < 0 || lastSpace == line.length() - 1) {
					System.out.println("Skipping malformed line: " + line);
					continue;
				}

				String stack = line.substring(0, lastSpace).trim();
				String countStr = line.substring(lastSpace + 1).trim();

				int count;
				try {
					count = Integer.parseInt(countStr);
				} catch (NumberFormatException e) {
					System.out.println("Skipping line with invalid count: " + line);
					continue;
				}
				
//				if (line.contains("moobench/benchmark/BenchmarkMain.main")) {
//					continue;
//				}
//				
//				if (line.startsWith("[unknown_Java]")) {
//					System.out.println("Skipping [unknown_Java]");
//					continue;
//				}
				
				String[] frames = stack.split(";");
				CallTreeNode current = root;
				root.setCalls(root.getCalls() + count);
				for (String frame : frames) {
					// Split class/method by last '.'
					int idx = frame.lastIndexOf('.');
					if (idx < 0) {
						if (frame.equals("__clock_gettime_2")) {
							current = current.getOrCreateChild("VSystem", "__clock_gettime_2");
							current.setCalls(current.getCalls() + count);
						}
						continue; // malformed
					}
						
					String clazz = frame.substring(0, idx).replace("/", ".");
					String method = frame.substring(idx + 1);
					current = current.getOrCreateChild(clazz, method);
					current.setCalls(current.getCalls() + count);
				}
			}
		}
		return root;
	}

	// Debug-Ausgabe (rekursiv)
	public static void printTree(CallTreeNode node, String indent) {
		if (!node.getClazz().equals("<root>")) {
			System.out.println(indent + node);
		}
		for (CallTreeNode child : node.getChildren()) {
			printTree(child, indent + "  ");
		}
	}
}
