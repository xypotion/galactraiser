function love.load()
	playerYAccel = 0
	playerXAccel = 0
		
	playerRect = {x=400, y=100, w=10, h=10, c={math.random(255), math.random(255), math.random(255)}}
	
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
	
	-- test_rectsOverlap()
end

function love.update(dt)	
	
	if love.keyboard.isDown("d") then
		playerXAccel = 10
	elseif love.keyboard.isDown("a") then
		playerXAccel = -10
	else
		playerXAccel = shortenVectorComponent(playerXAccel)
	end
	
	playerMove()
	
	-- actorHitsGroundOrCeiling(playerRect)
	-- actorHitsWalls(playerRect)
end

function love.draw()
	love.graphics.setColor(playerRect.c[1], playerRect.c[2], playerRect.c[3])
	love.graphics.rectangle("fill", playerRect.x, playerRect.y, playerRect.w, playerRect.h)
	
	for k,t in ipairs(terrain) do
		love.graphics.setColor(t.c[1], t.c[2], t.c[3])
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
		playerYAccel = -20
	end
end

function intInRange(locus, lowBound, span)
	return locus >= lowBound and locus < lowBound + span
end

--how about instead...
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

function playerMove()
	local actorWillHitFloor = false
	local actorHitCeiling = false
	local actorTouchingWall = false
	
	--the ONE terrain collision loop per frame
	for k,t in ipairs(terrain) do
		--on ground?
		-- actorOnFloor = actorOnFloor or rectsOverlap(t, applyVector(playerRect, {x=0,y=1})) --A LITTLE MORE ELEGANT, BUT...
		if not actorWillHitFloor then
			actorWillHitFloor, _, floorDiff = rectsOverlap(t, applyVector(playerRect, {x=0,y=playerYAccel}))
		end
		
		--hitting ceiling?
		if not actorHitCeiling then
			actorHitCeiling, _, ceilDiff = rectsOverlap(t, applyVector(playerRect, {x=0,y=-1}))
		end
		
		--hitting wall?
		actorTouchingWall = actorTouchingWall or rectsOverlap(t, applyVector(playerRect, {x=playerXAccel,y=0}))
	end
	
	
	
	-- adjust position if collision was detected
	if actorWillHitFloor and playerYAccel > 0 then
		-- if  then --so you can still jump
			playerYAccel = -floorDiff
		-- end
		-- playerRect.y = playerRect.y - floorDiff
	else 
		playerYAccel = playerYAccel + 1 
	end
	
	if actorHitCeiling then
		playerYAccel = 0
		playerRect.y = playerRect.y + 1 -- ceilDiff
	end
	
	if actorTouchingWall then
		playerXAccel = 0
		--and...
	end
	
	playerRect = applyVector(playerRect, {x=playerXAccel, y=playerYAccel})

	-- WAS THIS:
	-- playerRect = uncollideWithTerrain(playerRect, playerVector, 0)
end

-- function uncollideWithTerrain_boring(actor)--, vector)
-- 	local colliding = detectTerrainCollisionWith(actor)
--
-- 	while(false and colliding) do
-- 		-- vector.x, vector.y = vector.x - 1, vector.y - 1
-- 		colliding = detectTerrainCollisionWith(actor)
-- 	end
-- end

--split into uncollideX and uncollideY. just call one or the other from ONE loop through all terrain. you're looping way too much
function uncollideWithTerrain(actor, vector, n)
	-- print("vector: "..vector.x.." "..vector.y)
	
	if n < 10 and detectTerrainCollisionWith(applyVector(actor, vector)) then
		vector = shortenVector(vector)
		return uncollideWithTerrain(actor, vector, n + 1)
		-- print("hmm "..n)
	else
		-- print()
		
		return applyVector(actor, vector)
		
		-- local destination = applyVector(actor, vector)
		-- return destination.x, destination.y
	end
end

function detectTerrainCollisionWith(actor)
	local colliding = false
	
	for k,t in ipairs(terrain) do
		if rectsOverlap(actor, t) then
			colliding = true
			break
		end	
	end
	
	return colliding
end

function applyVector(actor, vector)
	return {x=actor.x + vector.x, y=actor.y + vector.y, h=actor.h, w=actor.w, c=actor.c}
end
--
-- function shortenVector(vector)
-- 	return {x=shortenVectorComponent(vector.x), y=shortenVectorComponent(vector.y)}
-- end

function shortenVectorComponent(vc)
	if vc > 0 then
		-- vc = vc - 1
		vc = math.floor(vc/2.0)
	elseif vc < 0 then
		-- vc = vc + 1
		vc = math.ceil(vc/2.0)
	end
	
	return vc
	-- return math.floor(vc/2.0)
end

-- function actorHitsTerrainBelow(actor, t)
-- 	if rectsOverlap(t,applyVector(actor, {x=0,y=1})) then
-- 		-- playerYAccel = 0
-- 		-- actorOnFloor = true
-- 	end
-- end
	

function actorHitsGroundOrCeiling(actor)
	local below = applyVector(actor, {x=0,y=1})
	local above = applyVector(actor, {x=0,y=-1})
	local actorOnFloor = false
	local actorHitCeiling = false
	
	for k,t in ipairs(terrain) do
		if rectsOverlap(t,below) then
			playerYAccel = 0
			actorOnFloor = true
		end
		
		if rectsOverlap(t,above) then
			playerYAccel = 0
			playerRect.y = playerRect.y + 1 --so you don't stick to the ceiling
			actorHitCeiling = true
		end
	end
	
	if not actorOnFloor and not actorHitCeiling and playerYAccel <= 20 then
		playerYAccel = playerYAccel + 1
	end
end
--combine ^^^ and vvv
function actorHitsWalls(actor) 
	-- local left = applyVector(actor, {x=-1,y=0})
	-- local right = applyVector(actor, {x=1,y=0})
	local side = applyVector(actor, {x=playerXAccel,y=0})
	local actorTouchingWall = false
	-- local actorTouchingRightWall = false
	
	for k,t in ipairs(terrain) do
		if rectsOverlap(t,side) then
		-- if rectsOverlap(t,left) or rectsOverlap(t,right) then
			playerXAccel = 0
			actorTouchingWall = true
			break
		end
	end
	
	-- if not actorOnFloor and not actorHitCeiling and playerYAccel <= 20 then
	-- 	playerYAccel = playerYAccel + 1
	-- end
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