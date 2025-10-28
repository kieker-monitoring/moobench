package moobench.tools.flamegraphs;

import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

enum METHOD_TYPES {
	TIME, METADATA, CALL_TREE, MEMORY, QUEUE
}

public class FindMappings {
	static Map<String, METHOD_TYPES> knownMapping = new HashMap<>();

	static {
		knownMapping.put("co.elastic.apm.agent.impl.transaction.EpochTickClock#getEpochMicros", METHOD_TYPES.TIME);
		knownMapping.put("co.elastic.apm.agent.impl.transaction.AbstractSpanImpl#getDurationMs", METHOD_TYPES.TIME);
		knownMapping.put("co.elastic.apm.agent.impl.ActiveStack#deactivate", METHOD_TYPES.CALL_TREE);
		knownMapping.put("TransactionImpl#beforeEnd", METHOD_TYPES.METADATA);
		knownMapping.put("SpanImpl#beforeEnd", METHOD_TYPES.METADATA);
//		knownMapping.put("SpanImpl#afterEnd", METHOD_TYPES.METADATA);
		knownMapping.put("co.elastic.apm.agent.impl.transaction.TransactionImpl#trackMetrics", METHOD_TYPES.METADATA);
		knownMapping.put("co.elastic.apm.agent.impl.transaction.AbstractSpanImpl$ChildDurationTimer#onSpanEnd",
				METHOD_TYPES.METADATA);
		knownMapping.put("ApmServerReporter#report", METHOD_TYPES.METADATA);
		knownMapping.put("SpanAtomicReference#incrementReferencesAndGet", METHOD_TYPES.CALL_TREE);
		knownMapping.put("co.elastic.apm.agent.impl.ElasticApmTracer#activate", METHOD_TYPES.CALL_TREE);
		knownMapping.put("co.elastic.apm.agent.impl.ElasticApmTracer#deactivate", METHOD_TYPES.CALL_TREE);
		knownMapping.put("co.elastic.apm.agent.impl.transaction.SpanImpl#incrementReferences", METHOD_TYPES.CALL_TREE);
		knownMapping.put("java.util.concurrent.atomic.AtomicInteger#decrementAndGet", METHOD_TYPES.CALL_TREE);
		
//		knownMapping.put("co.elastic.apm.agent.impl.transaction.SpanImpl#decrementReferences", METHOD_TYPES.CALL_TREE);
		
		
		
		knownMapping.put("co.elastic.apm.agent.impl.ElasticApmTracer#createSpan", METHOD_TYPES.MEMORY);
		knownMapping.put("co.elastic.apm.agent.impl.transaction.SpanImpl#recycle", METHOD_TYPES.MEMORY);
		knownMapping.put("co.elastic.apm.agent.impl.transaction.SpanImpl#start", METHOD_TYPES.CALL_TREE);
		knownMapping.put("co.elastic.apm.agent.impl.ElasticApmTracer#startRootTransaction", METHOD_TYPES.METADATA);
		knownMapping.put("co.elastic.apm.agent.impl.ElasticApmTracer#currentContext", METHOD_TYPES.METADATA);
		knownMapping.put("co.elastic.apm.agent.impl.ElasticApmTracer#reportSpan", METHOD_TYPES.METADATA);
		// Storing extended metrics and metadata that are calculated ad hoc

		knownMapping.put("kieker.monitoring.queue.behavior.BlockOnFailedInsertBehavior#insert", METHOD_TYPES.QUEUE);
		knownMapping.put("kieker.monitoring.core.registry.ControlFlowRegistry#getAndStoreUniqueThreadLocalTraceId",
				METHOD_TYPES.CALL_TREE);
		knownMapping.put("kieker.monitoring.core.registry.ControlFlowRegistry#unsetThreadLocalTraceId",
				METHOD_TYPES.CALL_TREE);
		knownMapping.put("kieker.monitoring.core.registry.ControlFlowRegistry#incrementAndRecallThreadLocalEOI",
				METHOD_TYPES.CALL_TREE);
		knownMapping.put("kieker.common.record.controlflow.OperationExecutionRecord#<init>", METHOD_TYPES.MEMORY);
		knownMapping.put("kieker.monitoring.core.registry.ControlFlowRegistry#recallAndIncrementThreadLocalESS",
				METHOD_TYPES.MEMORY);
		knownMapping.put("kieker.monitoring.timer.SystemNanoTimer#getTime", METHOD_TYPES.TIME);
		knownMapping.put("VSystem#__clock_gettime_2", METHOD_TYPES.TIME);
		knownMapping.put("kieker.monitoring.core.registry.ControlFlowRegistry#recallThreadLocalTraceId",
				METHOD_TYPES.CALL_TREE);

		knownMapping.put(
				"io.opentelemetry.javaagent.shaded.instrumentation.api.incubator.semconv.code.CodeAttributesExtractor#onStart",
				METHOD_TYPES.METADATA);
		knownMapping.put("io.opentelemetry.instrumentation.api.incubator.semconv.code.CodeAttributesExtractor#onStart",
				METHOD_TYPES.METADATA);
		knownMapping.put(
				"io.opentelemetry.javaagent.shaded.instrumentation.api.incubator.semconv.code.CodeSpanNameExtractor#extract",
				METHOD_TYPES.METADATA);
		knownMapping.put(
				"io.opentelemetry.javaagent.shaded.io.opentelemetry.api.incubator.trace.ExtendedSpanBuilder#setAllAttributes",
				METHOD_TYPES.METADATA);
		knownMapping.put(
				"io.opentelemetry.javaagent.tooling.asyncannotationsupport.WeakRefAsyncOperationEndStrategies#resolveStrategy ",
				METHOD_TYPES.METADATA);
		knownMapping.put("io.opentelemetry.sdk.trace.RandomIdGenerator#generateSpanId", METHOD_TYPES.METADATA);
		knownMapping.put("io.opentelemetry.sdk.trace.SdkSpan#setAttribute", METHOD_TYPES.METADATA);
		knownMapping.put("io.opentelemetry.sdk.trace.SdkTracer#spanBuilder", METHOD_TYPES.METADATA);
		knownMapping.put("io.opentelemetry.sdk.trace.ExtendedSdkSpanBuilder#setSpanKind", METHOD_TYPES.METADATA);
		knownMapping.put("io.opentelemetry.javaagent.instrumentation.methods.MethodAndType#getSpanKind",
				METHOD_TYPES.METADATA);
		knownMapping.put("io.opentelemetry.sdk.trace.AnchoredClock#create", METHOD_TYPES.TIME);
		knownMapping.put("io.opentelemetry.sdk.trace.AnchoredClock#now", METHOD_TYPES.TIME);
		knownMapping.put("io.opentelemetry.javaagent.shaded.io.opentelemetry.api.trace.Span#fromContext",
				METHOD_TYPES.CALL_TREE);
		knownMapping.put("io.opentelemetry.javaagent.shaded.io.opentelemetry.context.ArrayBasedContext#get",
				METHOD_TYPES.CALL_TREE);
		knownMapping.put("io.opentelemetry.javaagent.shaded.io.opentelemetry.context.Context#with",
				METHOD_TYPES.CALL_TREE);
		knownMapping.put("io.opentelemetry.javaagent.shaded.io.opentelemetry.context.Context#current",
				METHOD_TYPES.CALL_TREE);
		knownMapping.put("io.opentelemetry.javaagent.shaded.instrumentation.api.instrumenter.LocalRootSpan#isLocalRoot",
				METHOD_TYPES.CALL_TREE);
		knownMapping.put(
				"io.opentelemetry.javaagent.shaded.instrumentation.api.instrumenter.LocalRootSpan#fromContextOrNull",
				METHOD_TYPES.CALL_TREE);
		knownMapping.put("io.opentelemetry.javaagent.shaded.io.opentelemetry.api.internal.ImmutableSpanContext#create",
				METHOD_TYPES.CALL_TREE);
		knownMapping.put("io.opentelemetry.sdk.trace.export.BatchSpanProcessor$Worker#addSpan", METHOD_TYPES.QUEUE);
		knownMapping.put("io.opentelemetry.sdk.trace.SdkSpan#<init>", METHOD_TYPES.MEMORY);

		// Management of context via ThreadLocal Context object
		// Storing span id + span kind

//		knownMapping.put("io.opentelemetry.sdk.trace.SdkSpan#endInternal", METHOD_TYPES.GET_CALL_TREE);

	}

	Map<METHOD_TYPES, Integer> detections = new HashMap<METHOD_TYPES, Integer>();

	private List<CallTreeNode> unassignedChildren = new LinkedList<>();

	public void searchKnownMethods(CallTreeNode root) {
		searchKnownMethods(root, root);
		System.out.println();

		double sum = 0;
		for (METHOD_TYPES type : METHOD_TYPES.values()) {
			System.out.print(type + "\t");
		}
		System.out.println();

		for (METHOD_TYPES type : METHOD_TYPES.values()) {
			Integer calls = detections.getOrDefault(type, 0);
			double percentage = ((double) calls) / root.getCalls();
			sum += percentage;
			System.out.print(percentage + "\t");
		}
		System.out.println("Unexplained: " + (1 - sum));
		System.out.println();

		showUnassignedChildren();
		
		System.out.println();
		
		Set<String> pathes = showUniquePathToTime(root);
		for (String path : pathes) {
			System.out.println(path);
		}
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

	public Set<String> showUniquePathToTime(CallTreeNode current) {
		Set<String> pathes = new TreeSet<>();

		for (CallTreeNode child : current.getChildren()) {
			boolean found = false;
			for (Map.Entry<String, METHOD_TYPES> mapping : knownMapping.entrySet()) {
				if (mapping.getValue() == METHOD_TYPES.TIME && child.toString().contains(mapping.getKey())) {
//					System.out.println("Detected: " + child.toString());
					found = true;
					String currentPath = child.getClazz() + "#" + child.getMethod();
					CallTreeNode parent = child.getParent();
					currentPath = parent.getClazz() + "#" + parent.getMethod()+";" + currentPath;
					parent = parent.getParent();
					currentPath = parent.getClazz() + "#" + parent.getMethod()+";" + currentPath;
//					while (parent != null) {
//						currentPath = parent.getClazz() + "#" + parent.getMethod()+";" + currentPath;
//						parent = parent.getParent();
//					}
					pathes.add(currentPath);
				}
			}
			if (!found) {
				pathes.addAll(showUniquePathToTime(child));
			}
		}
		return pathes;
	}
}
