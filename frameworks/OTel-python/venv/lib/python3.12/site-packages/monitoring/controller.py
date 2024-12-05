# noqa: E402
# -*- coding: utf-8 -*-
import logging
from abc import ABC, abstractmethod
from monitoring.util import TimeStamp
from configparser import ConfigParser

# I think that calss can/should be removed. But in the future we might 
# have more complex MonitoringController 
class AbstractController(ABC):
    def __init__(self, domain, tcp_enabled, reader_thread, port,
                 terminated):
        self.domain = domain
        self.tcp_enabled = tcp_enabled
        self.reader_thread = reader_thread
        self.port = port
        self.terminated = terminated
        self.logger = logging.getLogger('ControllerLogger')
        self.threading = None

    @abstractmethod
    def initialize(self):
        if self.tcp_enabled is True:
            self.logger.info('Start Thread reader')
            self.threading.start()

    @abstractmethod
    def cleanup(self):
        if self.tcp_enabled:
            self.logger.info('Terminate')

    @abstractmethod
    def toString(self):
        pass


class SingleMonitoringController:
    ''' This class controlls the monitoring process. Only one instance of this class can exist at one time. '''
    __instance = None
   
    def __new__(cls, config=None):
        if SingleMonitoringController.__instance is None:
            SingleMonitoringController.__instance = object.__new__(cls)
        if config is not None:
            SingleMonitoringController.__instance.writer_controller = WriterController(config)
            SingleMonitoringController.__instance.time_source_controller = TimeSourceController(TimeStamp())
        return SingleMonitoringController.__instance
        

    def new_monitoring_record(self, record):
        ''' Delegates a record to a writer_controller'''
        # SingleMonitoringControler.__instance.writer_controller.new_monitoring_record is the same
        return self.writer_controller.new_monitoring_record(record) 
    
        
    
# This class can/should be removed since it does not provide something
# which cannot be achieved without it
class TimeSourceController(AbstractController):

    def __init__(self, time_source):
       
        self.time_source = time_source
    
    def initialize(self):
        pass

    def cleanup(self):
        pass

    def toString(self):
        pass
    
    def get_time(self):
        return self.time_source.get_time()


from monitoring.writer import FileWriter, TCPWriter, DummyWriter

class WriterController:
    ''' This class is responsible for how the record data is written.
        Depending on the provided configuration, the files are either written
        directly into a local file or is send via TCP to the remote
        data collector'''
    def __init__(self, config, path=None):
        if config is not None:
            config_parser = ConfigParser()
            config_parser.read(config)
            if not config_parser.items:
                raise ValueError('The configuration file is empty or could not be found.')

            mode = config_parser.get('General', 'mode')
            if mode == 'tcp':
                self.monitoring_writer = TCPWriter(config)
            elif mode == 'text':
                self.monitoring_writer = FileWriter(config_parser.get('FileWriter', 'file_path'), [])
            else:
                self.monitoring_writer = DummyWriter()
        else:
            raise ValueError('Path for configuration file was not provided.')
        
    def initialize(self):
        pass

    def cleanup(self):
        pass

    def new_monitoring_record(self, record):
        ''' Writes monitoring record.'''
        self.monitoring_writer.writeMonitoringRecord(record)
