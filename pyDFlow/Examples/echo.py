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
