package moobench.tools.flamegraphs;

import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

enum METHOD_TYPES {
	GET_TIME, GET_METADATA, GET_CALL_TREE, ALLOCATE, USE_ALLOCATED, QUEUE
}

public class FindMappings {
	static Map<String, METHOD_TYPES> knownMapping = new HashMap<>();
	
	static {
		knownMapping.put("co.elastic.apm.agent.impl.transaction.EpochTickClock#getEpochMicros", METHOD_TYPES.GET_TIME);
		knownMapping.put("co.elastic.apm.agent.impl.ActiveStack#deactivate", METHOD_TYPES.GET_CALL_TREE);
		knownMapping.put("TransactionImpl#beforeEnd", METHOD_TYPES.GET_METADATA);
		knownMapping.put("SpanImpl#beforeEnd", METHOD_TYPES.GET_METADATA);
		knownMapping.put("SpanImpl#afterEnd", METHOD_TYPES.GET_METADATA);
		knownMapping.put("SpanImpl#afterEnd", METHOD_TYPES.GET_METADATA);
		knownMapping.put("co.elastic.apm.agent.impl.transaction.TransactionImpl#trackMetrics", METHOD_TYPES.GET_METADATA);
		knownMapping.put("co.elastic.apm.agent.impl.transaction.AbstractSpanImpl$ChildDurationTimer#onSpanEnd", METHOD_TYPES.GET_METADATA);
		knownMapping.put("ApmServerReporter#report", METHOD_TYPES.GET_METADATA);
		knownMapping.put("SpanAtomicReference#incrementReferencesAndGet", METHOD_TYPES.GET_CALL_TREE);
		knownMapping.put("co.elastic.apm.agent.impl.ElasticApmTracer#activate", METHOD_TYPES.GET_CALL_TREE);
		knownMapping.put("co.elastic.apm.agent.impl.ElasticApmTracer#deactivate", METHOD_TYPES.GET_CALL_TREE);
		knownMapping.put("co.elastic.apm.agent.impl.ElasticApmTracer#createSpan", METHOD_TYPES.USE_ALLOCATED);
		knownMapping.put("co.elastic.apm.agent.impl.transaction.SpanImpl#start", METHOD_TYPES.GET_CALL_TREE);
		knownMapping.put("co.elastic.apm.agent.impl.ElasticApmTracer#startRootTransaction", METHOD_TYPES.GET_METADATA);
		knownMapping.put("co.elastic.apm.agent.impl.ElasticApmTracer#currentContext", METHOD_TYPES.GET_METADATA);
		
		knownMapping.put("kieker.monitoring.queue.behavior.BlockOnFailedInsertBehavior#insert", METHOD_TYPES.QUEUE);
		knownMapping.put("kieker.monitoring.core.registry.ControlFlowRegistry#getAndStoreUniqueThreadLocalTraceId", METHOD_TYPES.GET_CALL_TREE);
		knownMapping.put("kieker.monitoring.core.registry.ControlFlowRegistry#unsetThreadLocalTraceId", METHOD_TYPES.GET_CALL_TREE);
		knownMapping.put("kieker.monitoring.core.registry.ControlFlowRegistry#incrementAndRecallThreadLocalEOI", METHOD_TYPES.GET_CALL_TREE);
		knownMapping.put("kieker.common.record.controlflow.OperationExecutionRecord#<init>", METHOD_TYPES.ALLOCATE);
		knownMapping.put("kieker.monitoring.core.registry.ControlFlowRegistry#recallAndIncrementThreadLocalESS", METHOD_TYPES.ALLOCATE);
		knownMapping.put("kieker.monitoring.timer.SystemNanoTimer#getTime", METHOD_TYPES.GET_TIME);
		knownMapping.put("kieker.monitoring.core.registry.ControlFlowRegistry#recallThreadLocalTraceId", METHOD_TYPES.GET_TIME);
	}
	
	Map<METHOD_TYPES, Integer> detections = new HashMap<METHOD_TYPES, Integer>();
	
	private List<CallTreeNode> unassignedChildren = new LinkedList<>();
	
	public void searchKnownMethods(CallTreeNode root) {
		searchKnownMethods(root, root);
		System.out.println();
		
		double sum = 0;
		for (METHOD_TYPES type : METHOD_TYPES.values()) {
			Integer calls = detections.getOrDefault(type, 0);
			double percentage = ((double) calls) / root.getCalls();
			sum+=percentage;
			System.out.println(type + " " + percentage);
		}
		System.out.println("Unexplained: " + (1-sum));
		System.out.println();
		
		showUnassignedChildren();
	}

	private void showUnassignedChildren() {
		unassignedChildren.sort(new Comparator<CallTreeNode>() {

			@Override
			public int compare(CallTreeNode o1, CallTreeNode o2) {
				return o1.getCalls() - o2.getCalls();
			}
		});
		
		for (CallTreeNode child : unassignedChildren) {
			System.out.println("Detected unassigned child: ");
			CallTreeNode currentBack = child;
			while (currentBack != null) {
				System.out.println(" " + currentBack.toString());
				currentBack = currentBack.getParent();
			}
		}
	}
	
	public void searchKnownMethods(CallTreeNode current, CallTreeNode root) {
		for (CallTreeNode child : current.getChildren()) {
			
			boolean found = false;
			for (Map.Entry<String, METHOD_TYPES> mapping : knownMapping.entrySet()) {
				if (child.toString().contains(mapping.getKey())) {
//					System.out.println("Detected: " + child.toString());
					found = true;
					int addedValue = detections.getOrDefault(mapping.getValue(), 0) + child.getCalls();
					detections.put(mapping.getValue(), addedValue);
				}
			}
			if (!found) {
				if (!(child.getChildren().size() > 0)) {
					unassignedChildren.add(child);
				} else {
					searchKnownMethods(child, root);
				}
			}
		}
		
		
	}
}
