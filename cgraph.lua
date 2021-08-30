--[[

LUA MODULE

  cgraph (Version 1.0.0) - graph functions to project onto a cylindrical, 180 degree screen
	
SYNOPSIS

  local cgraph = require "cgraph"
  -- Variables
  t = t or 0
  t = t+framedelta()
  -- Initialize
  if not ini then
	g = {}
	for i = 1,inputs.size() do
		g[i] = cgraph.create()
	end
	ini = true
	cgraph:help()
  end
  -- Main Loop
  for i = 1,inputs.size() do
	g[i]:update(t,i)
  end
  
DESCRIPTION

  Developed for use with a CAREN, M-Gait, or GRAIL (https://www.motekmedical.com/).

API
	
	cgraph function list:

	cgraph.create()
	cgraph.getcycleduration()
	cgraph.getoffset()
	cgraph.getscaling()
	cgraph.gettrailduration()
	cgraph.gettrailupdate()
	cgraph.gettrailwidth()
	cgraph.help()
	cgraph.setcycleduration(duration)
	cgraph.setdistance(z)
	cgraph.setoffset(x,y)
	cgraph.setscaling(x,y)
	cgraph.settrailduration(duration)
	cgraph.settrailupdate(freq)
	cgraph.settrailwidth(value)
	cgraph.subplot(row,column,index)
	cgraph.update(x,y)

DEPENDENCIES

  D-Flow 3.34.0 (May work with earlier versions).
  Modules:
    - copy.lua
	- set outputs.lua
  
LICENSE
  
  Licensed under the same terms as Lua itself.
	
  Developers:
    William Denton - Midwestern University - 2021/08/30
	
--]]

-- Import modules
require "copy"
require "set outputs"

-- Variables
cgraph = cgraph or {
	Scaling = {
		1.0,	-- X
		1.0	-- Y
	},
	Offset = {
		0.0,	-- X
		0.0	-- Y
	},
	Distance = -5.0,	-- Z (Meters)
	Cycle = {
		Duration = 1.0	-- (Seconds)
	},
	Trail = {
		Update = {
			Freq = 60	-- (Hertz)
		},
		Duration = {
			Time = 10.0	-- (Seconds)
		},
		Width = {
			Value = 0.025	-- (Meters)
		},
		nCycles = 2
	}
}
OutputChannels = {
	"Trail.PosX",
	"Trail.PosY",
	"Trail.PosZ",
	"Transform.PosX",
	"Transform.PosY",
	"Transform.PosZ",
	"Transform.RotX",
	"Transform.RotY",
	"Transform.RotZ",
	"Update.Freq",
	"Duration.Time",
	"Width.Value"
}

-- Functions
function cgraph.help(self)
	print("cgraph (Version 1.0.0) - graph functions to project onto a curved, 180 degree screen")
	print("\t- Functions:")
	print("\t\t- create()")
	print("\t\t- getcycleduration:", cgraph["Cycle"]["Duration"])
	print("\t\t- getoffset:", cgraph["Offset"][1], cgraph["Offset"][2])
	print("\t\t- getscaling:", cgraph["Scaling"][1], cgraph["Scaling"][2])
	print("\t\t- gettrailduration:", cgraph["Trail"]["Duration"]["Time"])
	print("\t\t- gettrailupdate:", cgraph["Trail"]["Update"]["Freq"])
	print("\t\t- gettrailwidth:", cgraph["Trail"]["Width"]["Value"])
	print("\t\t- help()")
	print("\t\t- setcycleduration(duration)")
	print("\t\t- setdistance(z)")
	print("\t\t- setoffset(x,y)")
	print("\t\t- setscaling(x,y)")
	print("\t\t- settrailduration(duration)")
	print("\t\t- settrailupdate(freq)")
	print("\t\t- settrailwidth(value)")
	print("\t\t- subplot(row,column,index)")
	print("\t\t- update(x,y)")
	print("\t- Required Global Events:")
	print("\t\t- Reset Trail")
	for i = 1,cgraph["Trail"]["nCycles"] do
		print("\t\t- Stop Trail " .. tostring(i))
	end
end
function cgraph.create(self)
	return deepcopy(cgraph)
end
function cgraph.update(self,time,channel)
	local x = -1*self["Distance"]*math.sin(((time/self["Cycle"]["Duration"])%1-0.5)*math.pi*self["Scaling"][1]+self.Offset[1]*math.pi/2)
	local y = 1.15*self["Distance"] * ( inputs.get(channel) * self["Scaling"][2] + self["Offset"][2] - 0.53)
	local z = self["Distance"]*math.cos(((time/self["Cycle"]["Duration"])%1-0.5)*math.pi*self["Scaling"][1]+self.Offset[1]*math.pi/2)
	outputs.set(inputs.getname(channel) .. ".Trail.PosX",x)
	outputs.set(inputs.getname(channel) .. ".Trail.PosY",y)
	outputs.set(inputs.getname(channel) .. ".Trail.PosZ",z)
	outputs.set(inputs.getname(channel) .. ".Transform.PosX",c:getposition()[1])
	outputs.set(inputs.getname(channel) .. ".Transform.PosY",c:getposition()[2])
	outputs.set(inputs.getname(channel) .. ".Transform.PosZ",c:getposition()[3])
	outputs.set(inputs.getname(channel) .. ".Transform.RotX",c:getorientation()[1])
	outputs.set(inputs.getname(channel) .. ".Transform.RotY",c:getorientation()[2])
	outputs.set(inputs.getname(channel) .. ".Transform.RotZ",c:getorientation()[3])
	outputs.set(inputs.getname(channel) .. ".Update.Freq",self["Trail"]["Update"]["Freq"])
	outputs.set(inputs.getname(channel) .. ".Duration.Time",self["Trail"]["Duration"]["Time"])
	outputs.set(inputs.getname(channel) .. ".Width.Value",self["Trail"]["Width"]["Value"])
	if (time/self["Cycle"]["Duration"])%1 <= framedelta() then
		broadcast("Reset Trail")
		broadcast("Stop Trail " .. tostring(math.floor(time/self["Cycle"]["Duration"]%self["Trail"]["nCycles"]+1)))
	end
end
function cgraph.getscaling(self)
	return self["Scaling"]
end
function cgraph.setscaling(self,x,y)
	local x = x or self:getscaling()[1]
	local y = y or self:getscaling()[2]
	self["Scaling"] = {x,y}
end
function cgraph.getoffset(self)
	return self["Offset"]
end
function cgraph.setoffset(self,x,y)
	local x = x or self:getoffset()[1]
	local y = y or self:getoffset()[2]
	self["Offset"] = {x,y}
end
function cgraph.subplot(self,nrows,ncolumns,index)
	self:setscaling(1/ncolumns,1/nrows)
	local x = index%(ncolumns)
	if x == 0 then
		x = ncolumns
	end
	local y = math.floor((index-1)/ncolumns)+1
	self:setoffset(2*(x-1)/ncolumns-(ncolumns-1)/ncolumns,(y-1)/nrows)
end
function cgraph.getdistance(self)
	return self["Distance"]
end
function cgraph.setdistance(self,z)
	local z = z or self:getdistance()
	self["Distance"] = z
end
function cgraph.getcycleduration(self)
	return self["Cycle"]["Duration"]
end
function cgraph.setcycleduration(self,duration)
	local duration = duration or self:getcycleduration()
	self["Cycle"]["Duration"] = duration
end
function cgraph.gettrailupdate(self)
	return self["Trail"]["Update"]["Freq"]
end
function cgraph.settrailupdate(self,freq)
	local freq = freq or self:gettrailupdate()
	self["Trail"]["Update"]["Freq"] = freq
end
function cgraph.gettrailduration(self)
	return self["Trail"]["Duration"]["Time"]
end
function cgraph.settrailduration(self,time)
	local time = time or self:gettrailduration()
	self["Trail"]["Duration"]["Time"] = time
end
function cgraph.gettrailwidth(self)
	return self["Trail"]["Width"]["Value"]
end
function cgraph.settrailwidth(self,value)
	local value = value or self:gettrailwidth()
	self["Trail"]["Width"]["Value"] = value
end
-- Create output channels for each input channel
Outputs = {}
for i = 1,inputs.size() do
	for j = 1,#OutputChannels do
		table.insert(Outputs,inputs.getname(i) .. "." .. OutputChannels[j])
	end
end
setoutputs(
	Outputs
)
-- Make sure primary camera is attached
if objects.hasobject("PrimaryCamera") then
	c = c or objects.get("PrimaryCamera")
else
	error("You must attach the primary camera to the script.")
end
-- Return
return cgraph