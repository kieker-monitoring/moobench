# -*- coding: utf-8 -*-

from monitoring.serialization import Serializer, BinarySerializer
from monitoring.fileregistry import WriterRegistry
from configparser import ConfigParser


class DummyWriter:
    ''' This writer, is used to simulate writing, no records are written '''
    def __init__(self):
        pass

    def on_new_registry_entry(self, value, idee):
        pass

    def writeMonitoringRecord(self, record):
        pass

    def _serialize(self, record, idee):
        pass

    def onStarting(self):
        pass

    def on_terminating(self):
        pass

    def to_string(self):
        pass


class FileWriter:
    ''' This writer, is used to write the records directly into local files '''
    def __init__(self, file_path, string_buffer):
        self.file_path = file_path
        self.string_buffer = string_buffer
        self.serializer = Serializer(self.string_buffer)
        self.writer_registry = WriterRegistry(self)
        self.map_file_writer = MappingFileWriter()

    def on_new_registry_entry(self, value, idee):
        self.map_file_writer.add(value, idee)

    def writeMonitoringRecord(self, record):
        record_class_name = record.__class__.__module__ + record.__class__.__qualname__
        self.writer_registry.register(record_class_name)
        self._serialize(record, self.writer_registry.get_id(record_class_name))

    def _serialize(self, record, idee):
        # fetch record line
        header = f'{idee};'
        self.string_buffer.append(header)
        record.serialize(self.serializer)
        write_string = ''.join(map(str, self.string_buffer))+'\n'
        # clear buffer
        self.string_buffer.clear()
        # write to the file
        file = open(self.file_path, 'a')
        file.write(write_string)
        file.close()

    def onStarting(self):
        pass

    def on_terminating(self):
        pass

    def to_string(self):
        pass


class MappingFileWriter:
    def __init__(self):
        self.file_path = './record-map.log'

    def add(self, Id, class_name):
        file = open(self.file_path, 'a')
        write_string = f'$ {Id} = {class_name} \n'
        file.write(write_string)
        file.close()


from struct import pack
from monitoring.util import TimeStamp, get_prefix
import threading
import socket as s

lock = threading.Lock()

time = TimeStamp()
class TCPWriter:
    '''THis class is used to send the record data to a remote data collector. '''
    def __init__(self,  config):
        config_parser = ConfigParser()
        config_parser.read(config)
        self.socket = s.socket(s.AF_INET, s.SOCK_STREAM)
        # !!enable multiconnection on the collector and sender!!
        self.multConnections = config_parser.getboolean('General','multiple_Connections')
        self.host = config_parser.get('Tcp','host')
        self.port = config_parser.getint('Tcp', 'port')
        if not self.multConnections:
            self.socket.connect_ex((self.host, self.port))
        self.connetction_timeout = config_parser.getint('Tcp','connection_timeout')
        self.writer_registry = WriterRegistry(self)
        self.serializer = BinarySerializer([], self.writer_registry)

    def on_new_registry_entry(self, value, idee):
        # int - id, int-length, bytesequences
        # encode value in utf-8 and pack it with the id
        v_encode = str(value).encode('utf-8') # value should be always a string
        format_string = f'!iii{len(v_encode)}s'
        result = pack(format_string, -1, idee, len(v_encode), v_encode)
        try:
            if self.multConnections:
                self.socket.connect_ex((self.host, self.port))
                self.socket.sendall(result)
                self.socket.close()
            else:
                self.socket.sendall(result)
        except Exception as e:
            print(repr(e))  # TODO: better exception handling

    def writeMonitoringRecord(self, record):
        # fetch record name
        lock.acquire()
        record_class_name = record.__class__.__name__
        prefix = get_prefix(record_class_name)
        record_class_name = prefix + record_class_name
        # register class name and append it to the sent record
        self.writer_registry.register(record_class_name)
        self.serializer.put_string(record_class_name)
        self.serializer.put_long(time.get_time())
        # send record
        record.serialize(self.serializer)
        binarized_record = self.serializer.pack()
        lock.release()
        # try to send
        try:
            if self.multConnections:
                self.socket.connect_ex((self.host, self.port))
                self.socket.sendall(binarized_record)
                self.socket.close()
            else:
                self.socket.sendall(binarized_record)
        except Exception as e:
            # TODO: Better exception handling for tcp
            print(repr(e))

    def on_terminating(self):
        # TODO
        pass