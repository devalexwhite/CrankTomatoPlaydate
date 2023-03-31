function normalizeAngle(angle)
	if angle > 360 then
		return angle - 360
	elseif angle < 0 then
		return 360 + angle
	else
		return angle
	end
end