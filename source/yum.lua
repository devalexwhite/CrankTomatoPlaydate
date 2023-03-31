local gfx <const> = playdate.graphics

local yumImageTable = gfx.imagetable.new("images/yum")

class("Yum", { x, y }).extends(gfx.sprite)

function Yum:init(x, y)
	local w, h = yumImageTable:getImage(1):getSize()
	
	self:moveTo(x, y)
	self:setZIndex(10)
	self:animate()
end


function Yum:update()
	if not self.yumAnimation:isValid() then
		self:remove()
	else
		self:setImage(self.yumAnimation:image())
	end
end

function Yum:animate()
	self.yumAnimation = gfx.animation.loop.new(100, yumImageTable, false)
end