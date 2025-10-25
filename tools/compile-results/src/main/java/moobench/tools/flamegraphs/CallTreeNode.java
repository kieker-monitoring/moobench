package moobench.tools.flamegraphs;

import java.util.Set;
import java.util.TreeSet;

class CallTreeNode implements Comparable<CallTreeNode> {
	
	private final CallTreeNode parent;
	private final String clazz;
	private final String method;
	private final Set<CallTreeNode> children = new TreeSet<>();
	private int calls;

	public CallTreeNode(CallTreeNode parent, String clazz, String method) {
		this.parent = parent;
		this.clazz = clazz;
		this.method = method;
	}

	public String getClazz() {
		return clazz;
	}

	public String getMethod() {
		return method;
	}

	public int getCalls() {
		return calls;
	}

	public void setCalls(int calls) {
		this.calls = calls;
	}

	public Set<CallTreeNode> getChildren() {
		return children;
	}
	
	public CallTreeNode getParent() {
		return parent;
	}

	public CallTreeNode getOrCreateChild(String clazz2, String method2) {
		for (CallTreeNode c : children) {
			if (c.clazz.equals(clazz2) && c.method.equals(method2))
				return c;
		}
		CallTreeNode newNode = new CallTreeNode(this, clazz2, method2);
		children.add(newNode);
		return newNode;
	}

	@Override
	public int compareTo(CallTreeNode o) {
		return clazz.compareTo(o.clazz);
	}
	
	@Override
	public String toString() {
		return clazz + "#" + method + " " + calls;
	}
}