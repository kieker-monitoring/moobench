# TODO List

- Create the Moobench main application for Python in moobench/tools/pybenchmark 
  it should have the same configuration options as the Java version (see notes there)
- Create a script to run the benchmark (see Kieker/java/benchmark.sh as an example)
  The benchmark.sh script uses other scripts function.sh and labels.sh and some
  common-functions.
- the config.rc file should contain all configuration options for the script

The receiver tools is for TCP connections. Use this for your own TCP writer (it should work).

The lines 118ff in benchmark.sh contain the information on the different setups in Java.

Here the list of setups you should do:

1. PyMooBench without any options (baseline)
2. PyMooBench with woven probes, but inactive (you can do this with do nothing probes)
3. PyMooBench with woven probes, but a dummy writer (which does not write anything)

That could look like a little bit like:
class DummyWriter:
    ''' This writer, is used to write the records directly into local files '''
    def __init__(self, file_path, string_buffer):

    def on_new_registry_entry(self, value, idee):

    def writeMonitoringRecord(self, record):

    def _serialize(self, record, idee):

    def onStarting(self):
        pass

    def on_terminating(self):
        pass

    def to_string(self):
        pass

4. PyMooBench with woven probes using FileWriter
5. PyMooBench with woven probes using TCPWriter

**NOTE**: The only part of the application that is monitored is the method of
MonitoredClassSimple.


