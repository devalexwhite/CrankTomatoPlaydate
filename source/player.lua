local gfx <const> = playdate.graphics

local playerImage = gfx.image.new("images/player")

local playerBlinkImageTable = gfx.imagetable.new("images/playerBlink")

class("Player", { angle, speed, targetMouthAngle }).extends(gfx.sprite)

function Player:init(speed, angle)
	Tomato.super.init(self, playerImage)
	
	self.speed = speed
	self.angle = angle
	self.state = "normal"
	self.targetMouthAngle = GameConfig.initialMouthAngle
	self.mouthAngle = GameConfig.initialMouthAngle
	
	
	self:moveTo(200, 120)
	self:setImageDrawMode(gfx.kDrawModeWhiteTransparent)
end

function Player:update()
	self:CheckButtonPresses()
	self:setRotation(self.angle)
	
	if math.random(1,80) == 1 and self.state == "normal" then
		self:Blink()
	end
	
	local image
	
	
	if self.blinkAnimation ~= nil and self.blinkAnimation:isValid() then
		image = self.blinkAnimation:image()
	else
		image = playerImage
	end

	if self.chompAnimator ~= nil and self.chompAnimator:ended() then
		if self.mouthAngle >= 0 and self.chompAnimator:currentValue() <= 0 then
			self.chompAnimator = gfx.animator.new(500, 0, self.targetMouthAngle)
		end
	elseif self.chompAnimator ~= nil then
		self.mouthAngle = self.chompAnimator:currentValue()
	end
	
	local mask = self:CreateMouthMask()
	image:setMaskImage(mask)
	self:setImage(image)
	self:setZIndex(1)
end

function Player:CheckButtonPresses()
	if playdate.buttonIsPressed( playdate.kButtonUp ) then
		self.angle = (self.angle + 6) % 360
	end
	if playdate.buttonIsPressed( playdate.kButtonDown ) then
		self.angle = (self.angle - 6) % 360
	end
end

function Player:Blink()
	self.blinkAnimation = gfx.animation.loop.new(100, playerBlinkImageTable, false)
end

function Player:Cranked(change, accelChange)
	self.angle = playdate.getCrankPosition()
end

function Player:Chomp()
	if self.chompAnimator == nil or self.chompAnimator:ended() then
		self.chompAnimator = gfx.animator.new(500, self.mouthAngle, 0)
	end
end

function Player:CreateMouthMask()
	local width, height = playerImage:getSize()
	local mask = gfx.image.new(width, height, gfx.kColorWhite)
	
	gfx.lockFocus(mask)
	
	gfx.setColor(gfx.kColorBlack)
	gfx.setLineWidth(50)
	
	
	local startAngle =  90 - self.mouthAngle
	
	local endAngle = 91 + self.mouthAngle

	
	arc = playdate.geometry.arc.new(width/2, height/2, width/2, startAngle, endAngle)
	
	gfx.drawArc(arc)
	
	gfx.unlockFocus()
	
	return mask
end