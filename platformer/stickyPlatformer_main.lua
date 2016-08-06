function love.load()
	-- playerX = 400
	-- playerY = 100
	playerYAccel = 0
	playerXAccel = 0
	
	-- playerHeight = 10
	
	playerRect = {x=400, y=100, w=10, h=10}
	
	terrain = {}
	terrain[1] = {x=0, y=400, w=600, h=50}
	terrain[2] = {x=300, y=150, w=300, h=150}
	
	-- test_rectsOverlap()
end

function love.update(dt)	
	-- playerMoveVertically()
	playerMove()
	
	if love.keyboard.isDown("d") then
		-- playerRect.x = playerRect.x + 10
		playerXAccel = 10
	elseif love.keyboard.isDown("a") then
		-- playerRect.x = playerRect.x - 10
		playerXAccel = -10
	else
		playerXAccel = 0
	end
end

function love.draw()
	love.graphics.rectangle("fill", playerRect.x, playerRect.y, playerRect.w, playerRect.h)
	
	for i=1, table.getn(terrain) do
		local t = terrain[i]
		love.graphics.rectangle("fill", t.x, t.y, t.w, t.h)
	end
end

---------------------

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
	
	--jump!
	if key == "space" then
		playerYAccel = -15
	end
end

function intInRange(locus, lowBound, span)
	return locus >= lowBound and locus < lowBound + span
end

--how about instead...
function rectsOverlap(r1, r2)
	-- return (intInRange(r1.x, r2.x, r2.w) or intInRange(r2.x, r1.x, r1.w)) and (intInRange(r1.y, r2.y, r2.h) or intInRange(r2.y, r1.y, r1.h))
	return rectsOverlapHorizontal(r1, r2) and rectsOverlapVertical(r1, r2)
end

function rectsOverlapHorizontal(r1, r2)
	return intInRange(r1.x, r2.x, r2.w) or intInRange(r2.x, r1.x, r1.w)
end

function rectsOverlapVertical(r1, r2)
	return intInRange(r1.y, r2.y, r2.h) or intInRange(r2.y, r1.y, r1.h)
end


function old_playerMoveVertically()
	below = playerY + playerYAccel
	above = below - playerHeight
	local colliding = false
	local floor = playerY
	
	for k,t in ipairs(terrain) do
		if intInRange(playerX, t.locX, t.width) then --doesn't account for width of character
			if intInRange(below, t.locY, t.height) then
				colliding = true
				floor = t.locY
				break
			elseif intInRange(above, t.locY, t.height) then
				colliding = true
				floor = t.locY + t.height + playerHeight -- +1
				break
			end
		end
	end
	
	if colliding then
		playerY = floor
		playerYAccel = 0
	else
		playerY = below
		playerYAccel = playerYAccel + 1
	end
end

function playerMove()
	playerVTargetRect = {x=playerRect.x, y=playerRect.y + playerYAccel, w=playerRect.w, h=playerRect.h}
	playerHTargetRect = {x=playerRect.x + playerXAccel, y=playerRect.y, w=playerRect.w, h=playerRect.h}
	playerTargetRect = {x=playerRect.x + playerXAccel, y=playerRect.y + playerYAccel, w=playerRect.w, h=playerRect.h}
	
	playerProcessTerrainCollision()--playerTargetRect)
	-- playerRect = {x=playerRect.x + playerXAccel, y=playerRect.y + playerYAccel, w=playerRect.w, h=playerRect.h} -- simplify?
	playerRect.x = playerRect.x + playerXAccel
	playerRect.y = playerRect.y + playerYAccel
end

-- BUGS
-- TODO sticking to floor and walls! you haven't quite gotten this algo :/
-- TODO notice when falling from a long distance you stop and then start to fall again (accel = 0 before you land, then you fall again)

function playerProcessTerrainCollision() --or just playerMove
	-- below = playerRect.y + playerYAccel
	-- above = below - playerRect.h
	
	local horizColliding = false
	local vertColliding = false
	-- local floor = playerRect.y
	
	for k,t in ipairs(terrain) do
		-- if intInRange(playerX, t.locX, t.width) then --doesn't account for width of character
		-- 	if intInRange(below, t.locY, t.height) then
		-- 		colliding = true
		-- 		floor = t.locY
		-- 		break
		-- 	elseif intInRange(above, t.locY, t.height) then
		-- 		colliding = true
		-- 		floor = t.locY + t.height + playerHeight -- +1
		-- 		break
		-- 	end
		-- end
		
		-- if rectsOverlap(playerRect, t) then
	-- 		playerAccel = 0
	-- 		break
	-- 	end
		if rectsOverlap(playerTargetRect, t) then
			if --not horizColliding and 
			rectsOverlapHorizontal(playerHTargetRect, t) then
				--stop X movement
				horizColliding = true
				playerXAccel = 0
				-- print("foo " .. playerXAccel)
				
				-- break
			end
			
			if --not vertColliding and 
			rectsOverlapVertical(playerVTargetRect, t) then
				--stop Y movement
				vertColliding = true
				playerYAccel = 0
				
				-- if playerRect.y > t.y then
				-- 	playerRect.y = t.y - playerRect.h
				-- 	print(vertColliding)
				-- end
				-- print("bar " .. playerYAccel)
				
				-- break
			end
			
			-- colliding = true
			break
			-- floor = 
		end
	end
	
	-- if colliding then
	-- -- 	playerRect.y = floor
	-- 	playerYAccel = 0
	-- else
	-- -- 	playerRect.y = below
	-- 	playerYAccel = playerYAccel + 1
	-- end
		
		-- if colliding then
	-- if horizColliding then
	-- 	playerXAccel = 0
	-- -- else
	-- 	-- playerXAccel = playerXAccel -
	-- end
	
	if not vertColliding then
		-- playerYAccel = 0
	-- else
		playerYAccel = playerYAccel + 1
	end
end


-------------------------------- TESTS

function test_rectsOverlap()
	print("should all be false:")
	print(rectsOverlap({x=10, y=10, w=10, h=10}, {x=30, y=10, w=10, h=10})) -- wide miss
	print(rectsOverlap({x=10, y=10, w=10, h=10}, {x=10, y=30, w=10, h=10}))
	print(rectsOverlap({x=10, y=30, w=10, h=10}, {x=10, y=10, w=10, h=10}))
	print(rectsOverlap({x=30, y=10, w=10, h=10}, {x=10, y=10, w=10, h=10}))
	print(rectsOverlap({x=20, y=10, w=10, h=10}, {x=10, y=10, w=10, h=10})) -- edgy touchies
	print(rectsOverlap({x=10, y=20, w=10, h=10}, {x=10, y=10, w=10, h=10}))
	print(rectsOverlap({x=10, y=10, w=10, h=10}, {x=20, y=10, w=10, h=10}))
	print(rectsOverlap({x=10, y=10, w=10, h=10}, {x=10, y=20, w=10, h=10}))
	
	
	print("\nshould all be true:")
	print(rectsOverlap({x=10, y=10, w=10, h=10}, {x=10, y=10, w=10, h=10})) -- exact overlap
	
	print(rectsOverlap({x=1, y=1, w=100, h=100}, {x=10, y=10, w=10, h=10})) -- one inside other
	print(rectsOverlap({x=10, y=10, w=10, h=10}, {x=1, y=1, w=100, h=100}))
	
	print(rectsOverlap({x=15, y=10, w=10, h=10}, {x=10, y=10, w=10, h=10})) -- [<]>
	print(rectsOverlap({x=10, y=15, w=10, h=10}, {x=10, y=10, w=10, h=10}))
	print(rectsOverlap({x=10, y=10, w=10, h=10}, {x=15, y=10, w=10, h=10}))
	print(rectsOverlap({x=10, y=10, w=10, h=10}, {x=10, y=15, w=10, h=10}))
	
	print(rectsOverlap({x=15, y=10, w=5, h=10}, {x=10, y=10, w=10, h=10})) -- [[ ] 
	print(rectsOverlap({x=10, y=10, w=10, h=10}, {x=15, y=10, w=5, h=10}))
	print(rectsOverlap({x=10, y=10, w=5, h=10}, {x=10, y=10, w=10, h=10})) 
	print(rectsOverlap({x=10, y=10, w=10, h=10}, {x=10, y=10, w=5, h=10}))
	print(rectsOverlap({x=10, y=15, w=10, h=5}, {x=10, y=10, w=10, h=10}))
	print(rectsOverlap({x=10, y=10, w=10, h=10}, {x=10, y=15, w=10, h=5}))
	print(rectsOverlap({x=10, y=10, w=10, h=5}, {x=10, y=10, w=10, h=10}))
	print(rectsOverlap({x=10, y=10, w=10, h=10}, {x=10, y=10, w=10, h=5}))
		
	print(rectsOverlap({x=1, y=10, w=100, h=1}, {x=10, y=1, w=1, h=100})) -- -|-
	print(rectsOverlap({x=10, y=1, w=1, h=100}, {x=1, y=10, w=100, h=1}))
	
	print(rectsOverlap({x=15, y=15, w=10, h=10}, {x=10, y=10, w=10, h=10})) -- corners overlap
	print(rectsOverlap({x=10, y=15, w=10, h=10}, {x=15, y=10, w=10, h=10}))
	print(rectsOverlap({x=10, y=10, w=10, h=10}, {x=15, y=15, w=10, h=10}))
	print(rectsOverlap({x=15, y=10, w=10, h=10}, {x=10, y=15, w=10, h=10}))
	
	print(rectsOverlap({x=10, y=10, w=10, h=10}, {x=14, y=5, w=2, h=10})) -- sword in the stone
	print(rectsOverlap({x=10, y=10, w=10, h=10}, {x=5, y=14, w=10, h=2}))
	print(rectsOverlap({x=10, y=10, w=10, h=10}, {x=14, y=15, w=2, h=10}))
	print(rectsOverlap({x=10, y=10, w=10, h=10}, {x=15, y=14, w=10, h=2}))
	print(rectsOverlap({x=14, y=5, w=2, h=10}, {x=10, y=10, w=10, h=10}))
	print(rectsOverlap({x=5, y=14, w=10, h=2}, {x=10, y=10, w=10, h=10}))
	print(rectsOverlap({x=14, y=15, w=2, h=10}, {x=10, y=10, w=10, h=10}))
	print(rectsOverlap({x=15, y=14, w=10, h=2}, {x=10, y=10, w=10, h=10}))

	print(rectsOverlap({x=5, y=0, w=5, h=10}, {x=0, y=5, w=10, h=5})) -- |_
	print(rectsOverlap({x=0, y=5, w=10, h=5}, {x=5, y=0, w=5, h=10}))
	print(rectsOverlap({x=0, y=0, w=5, h=10}, {x=0, y=5, w=10, h=5}))
	print(rectsOverlap({x=0, y=5, w=10, h=5}, {x=0, y=0, w=5, h=10}))
	print(rectsOverlap({x=5, y=0, w=5, h=10}, {x=0, y=0, w=10, h=5}))
	print(rectsOverlap({x=0, y=0, w=10, h=5}, {x=5, y=0, w=5, h=10}))
	print(rectsOverlap({x=0, y=0, w=5, h=10}, {x=0, y=0, w=10, h=5}))
	print(rectsOverlap({x=0, y=0, w=10, h=5}, {x=0, y=0, w=5, h=10}))
end