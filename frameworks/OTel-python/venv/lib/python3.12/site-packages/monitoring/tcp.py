# -*- coding: utf-8 -*-
import socket
class TCPClient:
    ''' This is a wrapper class for the TCP connection. 
        Actually, this wrapper class is redundant, since we could establish
        a connection directly in the TCPWriter __init__().
        But, for some reason there is a broken Pipe error if we do so, and
        no problem arise if we wrap the operations in this class. 
    '''
    def __init__(self):
        self.port = None
        self.host = None
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        
    
    def set_port_and_host(self, port, host):
        self.port = port
        self.host = host
    
    def send(self, data):
        self.socket.sendall(data)
    
    def connect(self):
        # we use connect_ex() because by using conect() we get Soccket error 106:
        #'transport endpoint is already connected'
        self.socket.connect_ex((self.host, self.port))
        