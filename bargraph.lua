--[[

LUA MODULE

  bargraph (Version 1.0.0) - bargraph functions to display input values between 0 and 1.
	
SYNOPSIS

  require "bargraph"
  -- Initialize
  if not ini then
  	bar = {}
  	for i = 1,inputs.size() do
  		bar[i] = bargraph:init()
  	end
  	ini = true
  end
  -- Main Loop
  for i = 1,inputs.size() do
  	bar[i]:update(inputs.get(i))
  end
  
DESCRIPTION

  Developed for use with a CAREN, M-Gait, or GRAIL (https://www.motekmedical.com/).

API
	
	bargraph function list:

	bargraph.init()
	bargraph.create()
	bargraph.getaction()
	bargraph.setaction()
	bargraph.getdirection()
	bargraph.setdirection()
	bargraph.getheight()
	bargraph.setheight()
	bargraph.getorientation()
	bargraph.setorientation()
	bargraph.getposition()
	bargraph.setposition()
	bargraph.getsize()
	bargraph.setsize()
	bargraph.update()

	disk function list:
	
	disk.create()
	disk.getfade()
	disk.setfade()
	disk.getheight()
	disk.setheight()
	disk.getn()
	disk.setn()
	disk.getradius()
	disk.setradius()
	disk.getthickness()
	disk.setthickness()
	
	target function list:
	
	target.create()
	target.getcolor()
	target.setcolor()
	target.getalpha()
	target.setalpha()
	target.findcolor()
	target.getheight()
	target.setheight()
	target.getmax()
	target.setmax()
	target.getmin()
	target.setmin()
	target.getradius()
	target.setradius()
	
	outline function list:
	
	outline.create()
	outline.getcolor()
	outline.setcolor()
	outline.getalpha()
	outline.setalpha()
	outline.getheight()
	outline.setheight()
	outline.getradius()
	outline.setradius()
	
	audio function list:
	
	audio.getpositivefeedback()
	audio.setpositivefeedback()
	audio.getnegativefeedback()
	audio.setnegativefeedback()
	audio.getminvolume()
	audio.setminvolume()
	audio.getmaxvolume()
	audio.setmaxvolume()
	
DEPENDENCIES

  D-Flow 3.34.0 (May work with earlier versions).
  Modules:
	- copy.lua
	- set outputs.lua
		- contains.lua
  
LICENSE
  
  Licensed under the same terms as Lua itself.
	
  Developers:
    William Denton - Midwestern University - 2021/08/30
	
--]]


-- ____________________ Import ____________________ --
require "copy"
require "auditory feedback"


-- ____________________ Global variables ____________________ --
Direction = "Positive"
Height = 2.5
Orientation = "Vertical"
Position = {0,-2,-5}
Radius = 1


-- ____________________ Global functions ____________________ --
function normalize(x,max,min)
	return (x-min)/(max-min)
end
function removeambientemissivespecularcolors(material)
	material:setambientcolor(0,0,0)
	material:setemissivecolor(0,0,0)
	material:setspecularcolor(0,0,0)
end


-- ____________________ Target ____________________ --
target = target or {
	Color = {0,1,0,0.25},
	Direction = Direction,
	Height = Height,
	Maximum = 0.66667,
	Minimum = 0.33333,
	Object = nil,
	Orientation = Orientation,
	Position = Position,
	Radius = 1.01*Radius
}
-- Create
function target.create(self)
	local cylinder
	local material
	cylinder = object.create("Cylinder")
	cylinder:attachtocamera()
	material = cylinder:getmaterial()
	material:settransparency(true)
	material:setdiffusecolor(self["Color"])
	removeambientemissivespecularcolors(material)
	return cylinder
end
-- Color
function target.getcolor(self)
	return self["Color"]
end
function target.setcolor(self,r,g,b,a)
	local r = r or self:getcolor()[1]
	local g = g or self:getcolor()[2]
	local b = b or self:getcolor()[3]
	local a = a or self:getcolor()[4]
	local m = self["Object"]:getmaterial()
	m:setdiffusecolor(r,g,b,a)
	self["Color"] = {r,g,b,a}
end
function target.getalpha(self)
	return self["Color"][4]
end
function target.setalpha(self,a)
	local r = self:getcolor()[1]
	local g = self:getcolor()[2]
	local b = self:getcolor()[3]
	local a = a or self:getcolor()[4]
	local m = self["Object"]:getmaterial()
	m:setdiffusecolor(r,g,b,a)
	self["Color"] = {r,g,b,a}
end
function target.findcolor(self,position)
	local color
	if position <= self:getmin() then
		r = 3*(1 - position/self:getmin())/4+0.25
		g = position/self:getmin()
		b = 0
	elseif position > self:getmin() and position <= self:getmax() then
		r = math.abs((self:getmax() + self:getmin())/2 - position)
		g = 1 - math.abs((self:getmax() + self:getmin())/2 - position)
		b = math.abs((self:getmax() + self:getmin())/2 - position)
	else
		r = normalize(position,1,self:getmax())
		g = 1-normalize(position,1,self:getmax())
		b = 0
	end
	color = {
		r,
		g,
		b
	}
	return color
end
-- Height
function target.getheight(self)
	return self["Height"]
end
function target.setheight(self,height)
	local height = height or self:getheight()
	self["Object"]:setscaling( 
		height*(self:getmax()-self:getmin()),
		self:getradius(),
		self:getradius()
	)
	self["Height"] = height
end
-- Maximum
function target.getmax(self)
	return self["Maximum"]
end
function target.setmax(self,maximum)
	local maximum = maximum or self:getmax()
	self["Maximum"] = maximum
end
-- Minimum
function target.getmin(self)
	return self["Minimum"]
end
function target.setmin(self,minimum)
	local minimum = minimum or self:getmin()
	self["Minimum"] = minimum
end
-- Radius
function target.getradius(self)
	return self["Radius"]
end
function target.setradius(self,radius)
	local radius = radius or self:getradius()
	self["Object"]:setscaling( 
		self:getheight()*(self:getmax()-self:getmin()),
		radius,
		radius
	)
	self["Radius"] = radius
end


-- ____________________ Outline ____________________ --
outline = outline or {
	Color = {1,1,1,0.25},
	Direction = Direction,
	Height = Height,
	Object = nil,
	Orientation = Orientation,
	Position = Position,
	Radius = 0.99*Radius
}
function outline.create(self)
	local cylinder
	local material
	cylinder = object.create("Cylinder")
	cylinder:attachtocamera()
	material = cylinder:getmaterial()
	material:settransparency(true)
	material:setdiffusecolor(self["Color"])
	removeambientemissivespecularcolors(material)
	return cylinder
end
-- Color
function outline.getcolor(self)
	return self["Color"]
end
function outline.setcolor(self,r,g,b,a)
	local r = r or self:getcolor()[1]
	local g = g or self:getcolor()[2]
	local b = b or self:getcolor()[3]
	local a = a or self:getcolor()[4]
	local m = self["Object"]:getmaterial()
	m:setdiffusecolor(r,g,b,a)
	self["Color"] = {r,g,b,a}
end
function outline.getalpha(self)
	return self["Color"][4]
end
function outline.setalpha(self,a)
	local r = self:getcolor()[1]
	local g = self:getcolor()[2]
	local b = self:getcolor()[3]
	local a = a or self:getcolor()[4]
	local m = self["Object"]:getmaterial()
	m:setdiffusecolor(r,g,b,a)
	self["Color"] = {r,g,b,a}
end
-- Height
function outline.getheight(self)
	return self["Height"]
end
function outline.setheight(self,height)
	local height = height or self:getheight()
	self["Object"]:setscaling( 
		height*(self:getmax()-self:getmin()),
		self:getradius(),
		self:getradius()
	)
	self["Height"] = height
end
-- Radius
function outline.getradius(self)
	return self["Radius"]
end
function outline.setradius(self,radius)
	local radius = radius or self:getradius()
	self["Object"]:setscaling( 
		self:getheight(),
		radius,
		radius
	)
	self["Radius"] = radius
end


-- ____________________ Disk ____________________ --
disk = disk or {
	Counter = 0,
	Direction = Direction,
	Fade = 1,
	Height = Height,
	Number = 2,
	Object = {},
	Orientation = Orientation,
	Position = Position,
	Radius = 1.1*Radius,
	Thickness = 0.01
}
-- Create
function disk.create(self)
	local cylinder
	local material
	cylinder = object.create("Cylinder")
	cylinder:attachtocamera()
	material = cylinder:getmaterial()
	material:settransparency(true)
	removeambientemissivespecularcolors(material)
	cylinder:hide()
	return cylinder
end
-- Fade
function disk.getfade(self)
	return self["Fade"]
end
function disk.setfade(self,fade)
	local fade = fade or self["Fade"]
	self["Fade"] = fade
end
-- Height
function disk.getheight(self)
	return self["Height"]
end
function disk.setheight(self,height)
	local height = height or self:getheight()
	for i = 1,#self["Object"] do
		self["Object"][i]:setscaling( 
			height*self:getthickness(),
			self:getradius(),
			self:getradius()
		)
	end
	self["Height"] = height
end
-- Number
function disk.getn(self)
	return self["Number"]
end
function disk.setn(self,number)
	local number = number or self["Number"]
	self["Number"] = number
	for i = 1,self["Number"] do
		self["Object"][i] = disk.create()
	end
end
-- Radius
function disk.getradius(self)
	return self["Radius"]
end
function disk.setradius(self,radius)
	local radius = radius or self:getradius()
	for i = 1,#self["Object"] do
		self["Object"][i]:setscaling( 
			self:getheight()*self:getthickness(),
			radius,
			radius
		)
	end
	self["Radius"] = radius
end
-- Thickness
function disk.getthickness(self)
	return self["Thickness"]
end
function disk.setthickness(self,thickness)
	thickness = thickness or self:getthickness()
	for i = 1,#self["Object"] do
		self["Object"][i]:setscaling(thickness,self:getradius(),self:getradius(),"parent")
	end
	self["Thickness"] = thickness
end

-- ____________________ Sound ____________________ --
audio = audio or {
	Feedback = {
		Negative = nil,
		Positive = nil
	},
	Volume = {
		Minimum = 50,
		Maximum = 100
	}
}
-- Feedback
function audio.getpositivefeedback(self)
	return self["Feedback"]["Positive"]
end
function audio.setpositivefeedback(self,filename)
	local filename = filename or self:getpositivefeedback()
	self["Feedback"]["Positive"] = filename
end
function audio.getnegativefeedback(self)
	return self["Feedback"]["Negative"]
end
function audio.setnegativefeedback(self,filename)
	local filename = filename or self:getnegativefeedback()
	self["Feedback"]["Negative"] = filename
end
-- Volume
function audio.getminvolume(self)
	return self["Volume"]["Minimum"]
end
function audio.setminvolume(self,volume)
	local volume = volume or self:getminvolume()
	self["Volume"]["Minimum"] = volume
end
function audio.getmaxvolume(self)
	return self["Volume"]["Maximum"]
end
function audio.setmaxvolume(self,volume)
	local volume = volume or self:getmaxvolume()
	self["Volume"]["Maximum"] = volume
end


-- ____________________ Bar graph ____________________ --
bargraph = bargraph or {
	Action = nil,
	Direction = Direction,
	Disk = disk,
	Height = Height,
	Object = nil,
	Orientation = Orientation,
	Outline = outline,
	Position = Position,
	Radius = Radius,
	Target = target,
	Sound = audio
}
-- Initialize
function bargraph.init(self)
	local bg = deepcopy(self)
	bg["Object"] = bg:create()
	bg["Target"]["Object"] = bg["Target"]:create()
	bg["Target"]["Object"]:setposition(bg["Object"]:getposition("parent"),"parent")
	bg["Outline"]["Object"] = bg["Outline"]:create()
	bg["Outline"]["Object"]:setposition(bg["Object"]:getposition("parent"),"parent")
	for i = 1,bg["Disk"]["Number"] do
		bg["Disk"]["Object"][i] = disk.create()
	end
	bg:setposition()
	bg:setorientation()
	bg:setsize()
	return bg
end
-- Create
function bargraph.create(self)
	local cylinder
	local material
	cylinder = object.create("Cylinder")
	cylinder:attachtocamera()
	material = cylinder:getmaterial()
	removeambientemissivespecularcolors(material)
	return cylinder
end
-- Action
function bargraph.getaction(self)
	return self["Action"]
end
function bargraph.setaction(self,action)
	self["Action"] = action or self:getaction()
end
-- Direction
function bargraph.getdirection(self)
	return self["Direction"]
end
function bargraph.setdirection(self,direction)
	local direction = direction or self:getdirection()
	self["Direction"] = direction
	self["Target"]["Direction"] = direction
	self["Outline"]["Direction"] = direction
	self["Disk"]["Direction"] = direction
	self:setorientation()
end
-- Height
function bargraph.getheight(self)
	return self["Height"]
end
function bargraph.setheight(self,height)
	local height = height or self:getheight()
	self["Height"] = height
	self["Target"]["Height"] = height
	self["Outline"]["Height"] = height
	self["Disk"]["Height"] = height
	self["Object"]:setscaling(0,self["Radius"],self["Radius"])
	self["Target"]:setheight()
	self["Outline"]:setheight()
	self["Disk"]:setheight()
	self:setposition()
end
-- Orientation
function bargraph.getorientation(self)
	return self["Orientation"]
end
function bargraph.setorientation(self,orientation)
	orientation = orientation or self:getorientation()
	self["Orientation"] = orientation
	local rotation
	local direction
	if self["Direction"] == "Positive" then
		direction = 0
	elseif self["Direction"] == "Negative" then
		direction = 180
	end
	if self["Orientation"] == "Vertical" then
		rotation = {0,90,90+direction}
	elseif self["Orientation"] == "Horizontal" then
		rotation = {0,0,0+direction}
	end
	self["Object"]:setorientation(rotation,"parent")
	self["Target"]["Object"]:setorientation(rotation,"parent")
	self["Outline"]["Object"]:setorientation(rotation,"parent")
	for i = 1,#self["Disk"]["Object"] do
		self["Disk"]["Object"][i]:setorientation(rotation,"parent")
	end
	self:setposition()
end
-- Position
function bargraph.getposition(self)
	return self["Position"]
end
function bargraph.setposition(self,x,y,z)
	local x = x or self:getposition()[1]
	local y = y or self:getposition()[2]
	local z = z or self:getposition()[3]
	self["Position"] = {x,y,z}
	self["Object"]:setposition(x,y,z,"parent")
	self["Outline"]["Object"]:setposition(x,y,z,"parent")
	local direction
	if self["Direction"] == "Positive" then
		direction = 1
	elseif self["Direction"] == "Negative" then
		direction = -1
	end
	if self["Orientation"] == "Vertical" then
		y = y + direction*self["Height"]*self["Target"]["Minimum"]
	elseif self["Orientation"] == "Horizontal" then
		x = x + direction*self["Height"]*self["Target"]["Minimum"]
	end
	self["Target"]["Object"]:setposition(x,y,z,"parent")
end
-- Size
function bargraph.getsize(self)
	return {self["Radius"], self["Height"]}
end
function bargraph.setsize(self,radius,height)
	local ratio = 1
	if radius then
		ratio = radius/self["Radius"]
	end
	local radius = radius or self:getsize()[1]
	local height = height or self:getsize()[2]
	self["Radius"] = radius
	self["Target"]["Radius"] = ratio*self["Target"]["Radius"]
	self["Outline"]["Radius"] = ratio*self["Outline"]["Radius"]
	self["Disk"]["Radius"] = ratio*self["Disk"]["Radius"]
	self["Height"] = height
	self["Target"]["Height"] = height
	self["Outline"]["Height"] = height
	self["Disk"]["Height"] = height
	self["Object"]:setscaling(0,radius,radius)
	self["Outline"]["Object"]:setscaling(self["Height"],0.999*radius,0.999*radius)
	self["Target"]:setradius()
	self["Outline"]:setradius()
	self["Disk"]:setradius()
	self:setposition()
end
-- Update
function bargraph.update(self,value)
	self:setposition()
	self:setsize()
	local direction
	if self["Direction"] == "Positive" then
		direction = 1
	elseif self["Direction"] == "Negative" then
		direction = -1
	end
	-- Event
	if self["Action"] and hasaction(self["Action"]) then
		-- Update disk locations
		self["Disk"]["Counter"] = self["Disk"]["Counter"]+1
		for i = self["Disk"]["Number"],1,-1 do
			if i > 1 then
				self["Disk"]["Object"][i]:setposition(self["Disk"]["Object"][i-1]:getposition()[1],self["Disk"]["Object"][i-1]:getposition()[2],self["Disk"]["Object"][i-1]:getposition()[3])
				self["Disk"]["Object"][i]:getmaterial():setdiffusecolor(self["Disk"]["Object"][i-1]:getmaterial():getdiffusecolor())
			else
				if self["Orientation"] == "Vertical" then
					self["Disk"]["Object"][i]:setposition(self["Object"]:getposition("parent")[1],self["Object"]:getposition("parent")[2]+direction*value*self["Height"],self["Object"]:getposition("parent")[3],"parent")
				elseif self["Orientation"] == "Horizontal" then
					self["Disk"]["Object"][i]:setposition(self["Object"]:getposition("parent")[1]+direction*value*self["Height"],self["Object"]:getposition("parent")[2],self["Object"]:getposition("parent")[3],"parent")
				end
				self["Disk"]["Object"][i]:getmaterial():setdiffusecolor(unpack(self["Target"]:findcolor(value)))
			end
		end
		if self["Disk"]["Counter"] <= self["Disk"]["Number"] then
			self["Disk"]["Object"][self["Disk"]["Counter"]]:show()
		end	
		-- Auditory feedback
		if value >= self["Target"]:getmin() and value <= self["Target"]:getmax() then
			feedback(
				self["Sound"]:getpositivefeedback(),
				(self["Sound"]:getmaxvolume()-self["Sound"]:getminvolume())*2*(0.5-math.abs(normalize(value,self["Target"]:getmax(),self["Target"]:getmin())-0.5))+self["Sound"]:getminvolume(),
				self["Object"]:getposition()[1],
				self["Object"]:getposition()[2],
				self["Object"]:getposition()[3]
			)
		elseif value < self["Target"]:getmin() then
			feedback(
				self["Sound"]:getnegativefeedback(),
				(self["Sound"]:getmaxvolume()-self["Sound"]:getminvolume())*((1-normalize(value,self["Target"]:getmin(),0)))+self["Sound"]:getminvolume(),
				self["Object"]:getposition()[1],
				self["Object"]:getposition()[2],
				self["Object"]:getposition()[3]
			)
		elseif value > self["Target"]:getmax() then
			feedback(
				self["Sound"]:getnegativefeedback(),
				(self["Sound"]:getmaxvolume()-self["Sound"]:getminvolume())*((normalize(value,1,self["Target"]:getmax())))+self["Sound"]:getminvolume(),
				self["Object"]:getposition()[1],
				self["Object"]:getposition()[2],
				self["Object"]:getposition()[3]
			)
		end
	end
	for i = 2,self["Disk"]["Number"] do
		self["Disk"]["Object"][i]:getmaterial():setdiffusecolor(
			self["Disk"]["Object"][i]:getmaterial():getdiffusecolor()[1],
			self["Disk"]["Object"][i]:getmaterial():getdiffusecolor()[2],
			self["Disk"]["Object"][i]:getmaterial():getdiffusecolor()[3],
			self["Disk"]["Object"][i]:getmaterial():getdiffusecolor()[4]-framedelta()/self["Disk"]["Fade"]
		)
	end
	-- Update bar graph color
	self["Object"]:setscaling(value*self["Height"],self["Radius"],self["Radius"])
	m = self["Object"]:getmaterial()
	m:setdiffusecolor(unpack(self["Target"]:findcolor(value)))
end