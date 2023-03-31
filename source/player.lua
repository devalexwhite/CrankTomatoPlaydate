local gfx <const> = playdate.graphics

local playerImage = gfx.image.new("images/player")

local playerBlinkImageTable = gfx.imagetable.new("images/playerBlink")

class("Player", { angle, speed, targetMouthAngle }).extends(gfx.sprite)

function Player:init(speed, angle)
	Tomato.super.init(self, playerImage)
	
	self.speed = speed
	self.angle = angle
	self.state = "normal"
	self.targetMouthAngle = 25
	self.mouthAngle = self.targetMouthAngle
	
	
	self:moveTo(200, 120)
	self:setImageDrawMode(gfx.kDrawModeWhiteTransparent)
end

function Player:update()
	self:checkButtonPresses()
	self:setRotation(self.angle)
	
	if math.random(1,80) == 1 and self.state == "normal" then
		self:blink()
	end
	
	local image
	
	if self.state == "blinking" then
		if not self.blinkAnimation:isValid() then
			self.state = "normal"
			image = playerImage
		else
			image = self.blinkAnimation:image()
		end
	else
		image = playerImage
	end
	
	if self.state == "chompingDown" then
		if self.chompAnimator:ended() then
			self.state = "chompingUp"
			self.chompAnimator = gfx.animator.new(500, 0, self.targetMouthAngle)
		else
			self.mouthAngle = self.chompAnimator:currentValue()
		end
	elseif self.state == "chompingUp" then
		if self.chompAnimator:ended() then
			self.state = "normal"
		else
			self.mouthAngle = self.chompAnimator:currentValue()
		end
	end
	
	
	local mask = self:CreateMouthMask()
	
	image:setMaskImage(mask)
	
	
	self:setImage(image)
	self:setZIndex(1)
end

function Player:checkButtonPresses()
	if playdate.buttonIsPressed( playdate.kButtonUp ) then
		self.angle = (self.angle + 10) % 360
	end
	if playdate.buttonIsPressed( playdate.kButtonDown ) then
		self.angle = (self.angle - 10) % 360
	end
end

function Player:blink()
	self.state = "blinking"
	
	self.blinkAnimation = gfx.animation.loop.new(100, playerBlinkImageTable, false)
end

function Player:cranged(change, accelChange)
	self.angle = playdate.getCrankPosition()
end

function Player:Chomp()
	
	if self.state ~= "chompingDown" and self.state ~= "chompingUp" then
		self.state="chompingDown"
		self.chompAnimator = gfx.animator.new(100, self.mouthAngle, 0)
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