local gfx <const> = playdate.graphics

local tomatoImage = gfx.image.new("images/tomato")
local TomatoSprite = gfx.sprite.new(tomatoImage)

local tomatoSplatImageTable = gfx.imagetable.new("images/tomatoSplat")

class("Tomato", { x, y, angle, speed }).extends(gfx.sprite)




function Tomato:init(x, y, angle, speed)
	Tomato.super.init(self, tomatoImage)
	
	self:moveTo(x, y)
	
	self.speed = speed
	self.state = "moving"
	self.angle = angle
end

function Tomato:update()

	
	local angle = math.atan2(120 - (self.y + 16), 200 - (self.x + 16))
	local dist = math.sqrt(math.floor(self.x + 16 - 200) ^ 2 + math.floor(self.y + 16 - 120) ^ 2)
	
	local newX = self.x + math.cos(angle) * self.speed
	local newY = self.y + math.sin(angle) * self.speed
	

	
	if self.state == "moving" then
		self:moveTo(newX, newY)
	elseif self.state == "splatting" and self.splatAnimation:isValid() then
		self:setImage(self.splatAnimation:image())
	elseif self.state == "splatting" then
		self.state = "splatted"
		self:remove()
	end
	self:setZIndex(2)
end

function Tomato:splat()
	self.state = "splatting"
	
	self.splatAnimation = gfx.animation.loop.new(100, tomatoSplatImageTable, false)
end