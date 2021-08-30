--[[

LUA MODULE

  set inputs (Version 1.0.0) - sets input channel names.
	
SYNOPSIS

  require "set inputs"
  setinputs({"Input 1", "Input 2"})

DESCRIPTION

  Developed for use with a CAREN, M-Gait, or GRAIL (https://www.motekmedical.com/).

API
	
	setinputs({})

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
function setinputs(ChannelNames)
	for input = 1,#ChannelNames do
		if input > inputs.size() or not contains(ChannelNames,inputs.getname(input)) then
			inputs.setchannels(unpack(ChannelNames))
		end
	end
end