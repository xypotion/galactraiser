function love.load()
	playerYAccel = 0
	playerXAccel = 0
	
	baseAccel = 3
	
	-- inMemoryZone = {x=-100, y=-100, w=700, h=800}
	inMemoryZone = {x=-100, y=-100, w=900, h=800}
		
	playerRect = {x=400, y=100, w=30, h=20, c={math.random(255), math.random(255), math.random(255)}}
	playerPreviousRect = {x=400, y=100}
	
	terrain = {}
	terrain[1] = {x=0, y=400, w=600, h=50, c={math.random(255), math.random(255), math.random(255)}}
	terrain[2] = {x=300, y=300, w=300, h=50, c={math.random(255), math.random(255), math.random(255)}}
	terrain[3] = {x=100, y=200, w=100, h=50, c={math.random(255), math.random(255), math.random(255)}}
	terrain[4] = {x=200, y=200, w=100, h=50, c={math.random(255), math.random(255), math.random(255)}}
	terrain[5] = {x=600, y=100, w=100, h=100, c={math.random(255), math.random(255), math.random(255)}}
	terrain[6] = {x=600, y=200, w=100, h=100, c={math.random(255), math.random(255), math.random(255)}}
	terrain[7] = {x=600, y=500, w=45, h=50, c={math.random(255), math.random(255), math.random(255)}}
	terrain[8] = {x=650, y=500, w=45, h=50, c={math.random(255), math.random(255), math.random(255)}}
	terrain[9] = {x=500, y=500, w=45, h=50, c={math.random(255), math.random(255), math.random(255)}}
	terrain[10] = {x=550, y=500, w=45, h=50, c={math.random(255), math.random(255), math.random(255)}}
	
	bullets = {}
	
	-- test_rectsOverlap()
end

function love.update(dt)		
	if love.keyboard.isDown("s") and playerYAccel < baseAccel then
		playerYAccel = playerYAccel + baseAccel
	end
	
	if love.keyboard.isDown("w") and playerYAccel > -baseAccel then
		playerYAccel = playerYAccel - baseAccel
	end
	
	if love.keyboard.isDown("d") and playerXAccel < baseAccel then
		playerXAccel = playerXAccel + baseAccel
	end
	
	if love.keyboard.isDown("a") and playerXAccel > -baseAccel then
		playerXAccel = playerXAccel - baseAccel
	end
	
	-- playerMove()
	
	playerPreviousRect = {x=playerRect.x, y=playerRect.y}
	playerRect.x, playerRect.y = playerRect.x + playerXAccel, playerRect.y + playerYAccel
	
	for k,t in ipairs(terrain) do
		if rectsOverlap(playerRect, t) then
			hitTerrain(t)
		
			-- if rectsOverlapHorizontal(playerRect, t) then
			-- 	playerRect.x = playerPreviousRect.x
			-- 	playerXAccel = 0
			-- 	-- print("umm")
			-- end
			-- if rectsOverlapVertical(playerRect, t) then
			-- 	playerRect.y = playerPreviousRect.y
			-- 	playerYAccel = 0
			-- end
		end
	end
	
	updatePlayerBullets(dt)
	
	playerYAccel = 0--math.round(playerYAccel / 2)
	playerXAccel = 0--math.round(playerXAccel / 2)
	
	-- actorHitsGroundOrCeiling(playerRect)
	-- actorHitsWalls(playerRect)
end

function love.draw()
	for k,t in ipairs(terrain) do
		love.graphics.setColor(t.c[1], t.c[2], t.c[3])
		love.graphics.rectangle("fill", t.x, t.y, t.w, t.h)
	end
	
	love.graphics.setColor(playerRect.c[1], playerRect.c[2], playerRect.c[3])
	love.graphics.rectangle("fill", playerRect.x, playerRect.y, playerRect.w, playerRect.h)
	
	for k,t in ipairs(bullets) do
		love.graphics.setColor(t.c[1], t.c[2], t.c[3])
		love.graphics.rectangle("fill", t.x, t.y, t.w, t.h)
	end
end

---------------------

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
	
	if key == "space" then
		shoot()
	end
end

function shoot()
	table.insert(bullets, {x=playerRect.x + playerRect.w, y=playerRect.y + 5, w=10, h=10, c={math.random(255), math.random(255), math.random(255)}})
	
	-- table.remove(terrain, 4) --WORKS THE WAY YOU WANT IT TO! :)
end

function updatePlayerBullets(dt)	
	for k,b in ipairs(bullets) do
		local hitSomething = false
		
		for l,t in ipairs(terrain) do
			--BULLET COLLIDE WITH TERRAIN?
			if rectsOverlap(b,t) then
				print("bullet "..k.." hit terrain "..l)
				t.c={math.random(255), math.random(255), math.random(255)}
				-- table.remove(terrain, l)
				
				print("removing bullet "..k)
				table.remove(bullets, k)
				
				hitSomething = true
			end
		end
		
		--BULLET OFFSCREEN?
		if not hitSomething then
			if rectsOverlap(b, inMemoryZone) then
				b.x = b.x + dt * 100
			else
				print("unloading bullet "..k)
				table.remove(bullets, k)
			end
		end
	end
end

function hitTerrain(t)
	-- t.c = {math.random(255), math.random(255), math.random(255)}
	local terrain = t --TODO duh
	-- if t.x > playerRect.x then
	-- 	playerRect.x = t.x - playerRect.w
	-- elseif t.x <= playerRect.x then
	-- 	playerRect.x = t.x + t.w
	-- elseif t.y > playerRect.y then
	-- 	playerRect.y = t.y - playerRect.h
	-- elseif t.y <= playerRect.y then
	-- 	playerRect.y = t.y + t.h
	-- end

	-- playerRect.x, playerRect.y = playerPreviousRect.x, playerPreviousRect.y
	-- playerXAccel = 0
	-- playerYAccel = 0
	
	if terrain.x >= playerRect.x and terrain.x <= playerRect.x + playerRect.w then
		playerRect.x = terrain.x - playerRect.w - 1
		
	elseif terrain.x + terrain.w >= playerRect.x and terrain.x + terrain.w <= playerRect.x + playerRect.w then
		playerRect.x = terrain.x + terrain.w + 1
		
	elseif terrain.y >= playerRect.y and terrain.y <= playerRect.y + playerRect.h then
		playerRect.y = terrain.y - playerRect.h - 1
		
	elseif terrain.y + terrain.h >= playerRect.y and terrain.y + terrain.h <= playerRect.y + playerRect.h then
		playerRect.y = terrain.y + terrain.h + 1
		
		--hate this. why so hard. googling now
		
	end
end

function rectsOverlap(r1, r2)
	local horizontalCollision, x = rectsOverlapHorizontal(r1, r2)
	local verticalCollision, y = rectsOverlapVertical(r1, r2)
	
	return horizontalCollision and verticalCollision, x, y
end

function rectsOverlapHorizontal(r1, r2)
	if intInRange(r1.x, r2.x, r2.w) or intInRange(r2.x, r1.x, r1.w) then
		return true, r1.x - r2.x
	else
		return false, 0
	end
end

function rectsOverlapVertical(r1, r2)
	if intInRange(r1.y, r2.y, r2.h) or intInRange(r2.y, r1.y, r1.h) then
		return true, r1.y - r2.y
	else
		return false, 0
	end
end

function intInRange(locus, lowBound, span)
	return locus >= lowBound and locus < lowBound + span
end