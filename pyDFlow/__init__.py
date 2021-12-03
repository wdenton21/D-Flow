#!/usr/bin/env python

"""Used to connect to D-Flow's Network Module.

This module will only work when D-Flow's Network Module is running in Server mode.

Example:
    # Echo - This example will echo the first channel back to the server.
    import pyDFlow

    YOUR_IP_ADDRESS = <YOUR IP ADDRESS>
    
    dflow = pyDFlow.NetworkModuleClient(name="pyEcho Example",ip=YOUR_IP_ADDRESS)
    dflow.connect()
    print(f"Connected to D-Flow ({dflow.ip})")
    channel1data = dflow.getChannelValue(1)
    print(f"Server's Input1 = {channel1data}")
    dflow.setChannelValue(1,channel1data)
    print(f"Echoing Server's Input1 ({channel1data}) to Server's Output1")
    dflow.disconnect()
    print(f"Disconnected from D-Flow ({dflow.ip})")
"""

import os, sys
import threading
import struct
import socket

__author__ = "Bill Denton"
__contact__ = "21denton@gmail.com"
__date__ = "Dec. 3, 2021"
__license__ = "GPL"
__version__ = "1.0"

class NetworkModuleClient:
    def __init__(self,name="pyDFlow",ip="10.135.45.145"):
        self.name = name
        self.ip = ip
        self.port = 3910
        self.maxNrOfChannels = 256
        self.channels = {
            "to": [float(0)]*self.maxNrOfChannels,
            "from": [float(0)]*self.maxNrOfChannels,
        }
    def setName(self,name):
        """Updates the client name, which appears in the Connection Status of the Nework Module.

        By default, the client's name is pyDFlow. The client name should be relevant to your application.

        Example:
            dflow.setName("My Application")
        """
        self.name = name
    def setIp(self,ip):
        """Updates the IP Address that the server is on.

        The IP address must match what is listen in D-Flow's Network Module in the IP Address field.

        Example:
            dflow.setIp("10.135.45.145")
        """
        self.ip = ip
    def connect(self):
        """Establishes connection with the Network Module.

        Example:
            dflow.connect()
        """
        def transceiver(self):
            """Keeps connnection open with the Network Module.
            """
            self.frame = 0
            while self.isconnected:
                self.frame = self.frame+1
                # Receive
                self.client.recv(272)
                for i in range(0,self.maxNrOfChannels):
                    self.channels["from"][i] = struct.unpack(">f",self.client.recv(4))[0]
                # Send
                ## Header - only sending clientName
                for i in range(0,16):
                    self.client.send(struct.pack("x"))
                for i in range(0,256):
                    if i < len(self.name):
                        self.client.send(struct.pack("<c",bytes(self.name[i],"utf-8")))
                    else:
                        self.client.send(struct.pack("x")) 
                ## Channels
                for i in range(0,self.maxNrOfChannels):
                    self.client.send(struct.pack(">f",self.channels["to"][i]))
            self.client.close()
        # Connect to D-Flow Server
        connection = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
        connection.connect((self.ip,self.port))
        # Read header information
        packetType = struct.unpack("<I", connection.recv(4))[0]
        nrOutputs = struct.unpack("<I", connection.recv(4))[0]
        nrInputs = struct.unpack("<I", connection.recv(4))[0]
        clientIndex = struct.unpack("<I", connection.recv(4))[0]
        name = connection.recv(self.maxNrOfChannels)
        for i in range(0,self.maxNrOfChannels):
            struct.unpack(">f",connection.recv(4))[0]
        # Communicate with D-Flow Server
        self.client = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
        self.client.connect((self.ip,self.port+clientIndex))
        self.isconnected = True
        self.thread = threading.Thread(target=transceiver,args=(self,))
        self.daemon = True
        self.thread.start()
    def getChannelValue(self,channel):
        """Returns the value of the specified channel.

        Example:
            val = dflow.getChannelValue(1)
        """
        self.update() # Force to update
        return self.channels["from"][channel-1]
    def setChannelValue(self,channel,value):
        """Sets the value of the specified channel.

        Example:
            dflow.setChannelValue(1,float(pyDFlow.__version__)) #Sets Output1 to the __version__ of pyDFlow
        """
        self.channels["to"][channel-1] = value
        self.update() # Force to update
    def disconnect(self):
        """Stops the connection with the Network Module.

        Example:
            dflow.disconnect()
        """
        self.isconnected = False
    class HiddenPrints:
        """Prevents the display of the print() function.

        Example:
            with HiddenPrints():
                print("This will not be printed")
            print("This will be printed as before")

        Credit: Alexander Chzhen (https://stackoverflow.com/users/2039471/alexander-c)
        """
        def __enter__(self):
            self._original_stdout = sys.stdout
            sys.stdout = open(os.devnull, 'w')
        def __exit__(self, exc_type, exc_val, exc_tb):
            sys.stdout.close()
            sys.stdout = self._original_stdout
    def update(self):
        """Forces the transceiver thread to share the most recent data.

        This is automatically called during getChannelValue and setChannelValue.

        Example:
            dflow.update()
        """
        # Hotfix to force class variables to update from thread - would like to find a better solution
        with self.HiddenPrints():
            print(self.frame)

if __name__ == "__main__":
    dflow = NetworkModuleClient()
    dflow.connect()

