# -*- coding: utf-8 -*-

from struct import pack

class Serializer:

    def __init__(self, string_byte):
        self.string_byte = string_byte

    def put(self, value):
        if value is not'\n':
            self.string_byte.append(str(value)+"; ")
        else:
            self.string_byte.append(value)

    def put_boolean(self, boolean):
        self.string_byte.append(str(boolean)+"; ")

    def put_byte(self, value):
        self.string_byte.append(str(value)+"; ")

    def put_int(self, value):
        self.string_byte.append(str(value)+"; ")

    def put_long(self, value):
        self.string_byte.append(str(value)+"; ")

    def put_double(self, value):
        self.string_byte.append(str(value)+"; ")

    def put_string(self, value):
        self.string_byte.append(str(value)+"; ")

    def put_char(self, value):
        self.string_byte.append(str(value)+"; ")

    def put_short(self, value):
        self.string_byte.append(str(value)+"; ")

    def put_float(self, value):
        self.string_byte.append(str(value)+"; ")

    def pack(self):
        raise NotImplementedError('pack() is not suppored by the file serializer.')
        


class BinarySerializer:

    def __init__(self, buffer, string_registry):
        self.buffer = buffer
        self.format_string = '!'
        self.string_registry = string_registry

    def put_boolean(self, boolean):
        self.buffer.append(boolean)
        self.format_string += '?'

    def put_byte(self, value):
        self.buffer.append(value)
        self.format_string += 'i'

    def put_int(self, value):
        self.buffer.append(value)
        self.format_string += 'i'

    def put_long(self, value):
        self.buffer.append(value)
        self.format_string += 'q'

    def put_double(self, value):
        self.buffer.append(value)
        self.format_string += 'd'

    def put_string(self, value):
        if value is '\n':
            return
        string_id = self.string_registry.get_id(value)
        self.buffer.append(string_id)
        self.format_string += 'i'

    def put_char(self, value):
        self.buffer.append(value)
        self.format_string += 'c'

    def put_short(self, value):
        self.buffer.append(value)
        self.format_string += 'h'

    def put_float(self, value):
        self.buffer.append(value)
        self.format_string += 'f'

    def pack(self):
        result = pack(self.format_string, *self.buffer)
        self.format_string = '!'
        self.buffer.clear()

        return result
