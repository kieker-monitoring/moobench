from opentelemetry.sdk.trace.export import SpanExporter, SpanExportResult

class EmptyExporter (SpanExporter):

    def __init__(self):
        pass

    def export(self, spans):
        return SpanExportResult.SUCCESS