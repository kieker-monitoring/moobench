package moobench.tools.results.stages;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Calendar;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;

import moobench.tools.results.data.Chart;
import moobench.tools.results.data.ValueTuple;
import teetime.framework.AbstractConsumerStage;

public class JsonChartSink extends AbstractConsumerStage<Chart> {

    private final Path path;

    public JsonChartSink(final Path path) {
        this.path = path;
    }

    @Override
    protected void execute(final Chart chart) throws Exception {
        final Path jsonLog = this.path.resolve(chart.getName() + "-partial.json");
        final ObjectMapper mapper = new ObjectMapper();

        final ObjectNode node = mapper.createObjectNode();
        final ArrayNode arrayNode = node.putArray("results");

        chart.sort();

        for(final ValueTuple value : chart.getValues()) {
            System.err.printf("time %d\n", value.getTimestamp());
            final ObjectNode objectNode = mapper.createObjectNode();
            for (int i = 0;i < chart.getHeaders().size();i++) {
                final String name = chart.getHeaders().get(i);
		if (value.getValues().size() < i) {
                    System.err.println("Problem in processing: i="+i+", size="+value.getValues().size());
                    System.err.println("Chart: " + chart.getName() + " Header: " + name);
		}
                final Double number = value.getValues().get(i);
                objectNode.put(name, number);
            }

            final Calendar calendar = Calendar.getInstance();
            calendar.setTimeInMillis(value.getTimestamp() * 1000);

            objectNode.put("time", String.format("%d-%d-%d",
                    calendar.get(Calendar.DAY_OF_MONTH), calendar.get(Calendar.MONTH)+1,
                    calendar.get(Calendar.YEAR)));
            arrayNode.add(objectNode);
        }

        mapper.writeValue(Files.newBufferedWriter(jsonLog), node);
    }

}
