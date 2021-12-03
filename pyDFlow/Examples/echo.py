# Echo - This example will echo the first channel back to the server.
import pyDFlow
dflow = pyDFlow.NetworkModuleClient(name="pyEcho Example",ip="10.135.45.145")
dflow.connect()
print(f"Connected to D-Flow ({dflow.ip})")
channel1data = dflow.getChannelValue(1)
print(f"Server's Input1 = {channel1data}")
dflow.setChannelValue(1,channel1data)
print(f"Echoing Server's Input1 ({channel1data}) to Server's Output1")
dflow.disconnect()
print(f"Disconnected from D-Flow ({dflow.ip})")
