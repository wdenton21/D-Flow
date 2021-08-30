--[[

LUA MODULE

  set outputs (Version 1.0.0) - sets output channel names.
	
SYNOPSIS

  require "set outputs"
  setoutputs({"Output 1", "Output 2"})

DESCRIPTION

  Developed for use with a CAREN, M-Gait, or GRAIL (https://www.motekmedical.com/).

API
	
	setoutputs({})

DEPENDENCIES

  D-Flow 3.34.0 (May work with earlier versions).
  Modules:
	- contains.lua
  
LICENSE
  
  Licensed under the same terms as Lua itself.
	
  Developers:
    William Denton - Midwestern University - 2021/08/30
	
--]]

-- Import modules
require("contains")

-- Functions
function setoutputs(ChannelNames)
	for output = 1,#ChannelNames do
		if output > outputs.size() or not contains(ChannelNames,outputs.getname(output)) then
			outputs.setchannels(unpack(ChannelNames))
		end
	end
end