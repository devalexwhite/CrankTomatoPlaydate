

-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"
import "CoreLibs/ui"

import "tomato"
import "player"
import "utils"
import "yum"

-- Declaring this "gfx" shorthand will make your life easier. Instead of having
-- to preface all graphics calls with "playdate.graphics", just use "gfx."
-- Performance will be slightly enhanced, too.
-- NOTE: Because it's local, you'll have to do it in every .lua source file.

local gfx <const> = playdate.graphics

-- Here's our player sprite declaration. We'll scope it to this file because
-- several functions need to access it.

local playerSprite = nil

-- A function to set up our game environment.

function chompTextAnimation()
	
	
	local r = playdate.geometry.rect.new(100, 10, 40, 40)
	
	local t = playdate.frameTimer.new(20, 10, 150, playdate.easingFunctions.inCubic)
	t.reverses = true
	t.repeats = true
	t.reverseEasingFunction = playdate.easingFunctions.outQuad
	t.updateCallback = function(timer)
		r.y = timer.value
	end
	

end

function spawnTomato()
	if gameState ~= "running" then
		return
	end
	local angle = math.random(1, 360)
	
	local sin = math.sin(angle)
	local cos = math.cos(angle)
	
	local tomatoX = 200 * cos + 200
	local tomatoY = 200 * sin + 120
	
	local tomato = Tomato(tomatoX, tomatoY, angle, math.random(1, 4))
	table.insert(tomatoes, tomato)
	tomato:add()
	
	playdate.timer.new(1000, spawnTomato)
end

function updateTime()
	if hasCranked == true then
		timeLeft -= 1
	end
	if timeLeft <= 0 then
		gameState = "end"
	end
	playdate.timer.new(1000, updateTime)
end

function cranckCheck()
	if hasCranked then
		playdate.timer.new(1000, spawnTomato)
		crankAlert = false
	else
		playdate.ui.crankIndicator:start()
		crankAlert = true
		playdate.timer.new(1000, cranckCheck)
	end
end

function setup()
	local backgroundImage = gfx.image.new( "images/background" )
	assert( backgroundImage )
	
	local gameoverBackground = gfx.image.new("images/gameoverBackground")
	gameState = "running"
	
	
	player = Player(10, 0)
	player:add()
	
	tomatoes = {}
	score = 0
	timeLeft = 15
	
	
	playdate.timer.new(1000, updateTime)
	playdate.timer.new(1000, cranckCheck)
	
	hasCranked = false
	crankAlert = false
	
	gfx.sprite.setBackgroundDrawingCallback(
		function( x, y, width, height )
			-- x,y,width,height is the updated area in sprite-local coordinates
			-- The clip rect is already set to this area, so we don't need to set it ourselves
			if gameState == "running" then
				backgroundImage:draw( 0, 0 )
			elseif gameState == "end" then
				gameoverBackground:draw(0,0)
			end
		end
	)
end

setup()

function playdate.update()
	local dist = 55
	playdate.graphics.clear()
	playdate.graphics.setLineWidth(4)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	
	if gameState == "running" then
		player:setVisible(true)
		for i,v in ipairs(tomatoes) do
			if v.state == "splatted" then
				table.remove(tomatoes, i)
			elseif v.x < 200 + dist and v.x > 200 - dist and v.y < 120 + dist and v.y > 120 - dist and v.state=="moving" then
			 	
				
				local mouthAngle = (player.angle) % 360
				
				local tomatoAngle = math.atan2((v.y) - 120, (v.x) - 200)
				
				tomatoAngle *= (180/math.pi)
				
				if tomatoAngle < 0 then
					tomatoAngle += 360
				end
	
				local angleDiff = math.abs(tomatoAngle - mouthAngle)
				
				if angleDiff <= player.targetMouthAngle  then
					score += 1
					player:Chomp()
					local yum = Yum(200, 50)
					yum:add()
				end
				
				v:splat()
			end
		end
		
		
		player.targetMouthAngle = (timeLeft / 30) * 25
		player.mouthAngle = (timeLeft / 30) * 25
		gfx.sprite:update()
		gfx.drawText(string.format("*%ss*", timeLeft),360, 10)
		if crankAlert then
			playdate.ui.crankIndicator:update()
		end
	elseif gameState == "end" then
		for i,v in ipairs(tomatoes) do
			v:remove()
			table.remove(tomatoes, i)
		end
		
		player:setVisible(false)
		gfx.sprite:update()
		gfx.drawText(string.format("I ate *%s* tomatoes", score), 200, 120)
		gfx.drawText("Press Ⓐ to play again", 200, 160)
	end
	
	
	playdate.timer.updateTimers()
end

function playdate.cranked(change, accelChange)
	hasCranked = true
	crankAlert = false
	player:cranged(change, accelChange)
end

