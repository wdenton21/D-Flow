function feedback(name,volume,x,y,z)
	x = x or 0
	y = y or 0
	z = z or 0
	if name then
		s = sound.create("D:\\CAREN Resources\\Sounds\\" .. name .. ".wav")
		s:setvolume(volume/100)
		s:play()
		s:setposition(x,y,z)
	end
end