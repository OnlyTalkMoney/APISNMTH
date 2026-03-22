local Players = game:GetService("Players") -- This service allows us to get players in game
local Workspace = game:GetService("Workspace") -- This service allows us to get things in workspace
local DataStoreSevice = game:GetService("DataStoreService") -- This service allows us to load and save data
local GroupService = game:GetService("GroupService") -- This service allows us to get infos about group but in script also you can use grouppromptjoin for player to join group in localscript
local MarketPlaceService = game:GetService("MarketplaceService") -- This service allows us to buy gamepasses or dev products
local TweenService = game:GetService("TweenService") -- This service allows us to give animations to things or you can change their properties too with that
local Debris = game:GetService("Debris") -- This service allows us to delete things smoothly first arg is instance of part, second arg is lifetime of part like if we give 10 seconds to second arg it will delete it after 10 seconds
local RunService = game:GetService("RunService") -- This service allows us to run every frame on game this is very useful functional example you can make a fps indicator
local UserService = game:GetService("UserService") -- This service allows us to get info about players with players id
local HttpService = game:GetService("HttpService") -- This service allows us to get info from web or you can send it to web
local BadgeService = game:GetService("BadgeService") -- This service allows us to give badges to players
local TeleportService = game:GetService("TeleportService") -- This service allows us to teleport player to another server or another game
local PathFinding = game:GetService("PathfindingService") -- This service allows us to make npcs make and find their path

-- MainDataStore Name
local MainData = DataStoreSevice:GetDataStore("MainData") -- Datastore name of player data

-- Workspace Parts
local AllPartFolder = workspace:WaitForChild("AllPart")
local DecalPart = AllPartFolder:WaitForChild("DecalPart")
local GroupDecal = DecalPart:WaitForChild("GroupDecal")
local TeleportPart = AllPartFolder:WaitForChild("TeleportPart")
local EndPos = AllPartFolder:WaitForChild("EndPos")
local Npc1 = AllPartFolder:WaitForChild("Npc1")
local NpcHumanoidRootPart = Npc1:WaitForChild("HumanoidRootPart")
local NpcHumanoid = Npc1:WaitForChild("Humanoid")
local DetectPartsFolder = Workspace:WaitForChild("DetectParts")
local Part = AllPartFolder:WaitForChild("TurnPart")

local playerids = {
	8617957446,
	448291078,
	250511428
}

local DetectParts = {}

local discurl = "https://discord.com/api/webhooks/1484565234307043389/ahJYXl_fOC22an3pCNlixgY3sLrrDSio8dfPo-8kEN5smQSheYUQJGN6j-MRs4dM1LFS" -- Discord Webhook Bot Id for send message to discord channel

local BADGE_ID = 142913938100904 -- BadgeID for BadgeService

local groupId = 815506267 -- GroupID for GroupService

local gamepassid = 1759631181  -- GamepassID for MarketPlaceService

local PLACE_ID = 84112300473474 -- PlaceId for TeleportService

local raycastParamps = RaycastParams.new() -- Creates a raycastparamps that useful for detect something or find smth with our mouse or detect smth with our mouse VERY USEFUL 
raycastParamps.FilterDescendantsInstances = {} -- Thats the part that we dont want to filter
raycastParamps.FilterType = Enum.RaycastFilterType.Exclude -- Every part gonna be ignored except these in filterdescendantsinstances but if i use include parts in filterdescandts will be considered

local function turnpartmath(Part) -- This function is used for turning part i called it with coroutine.wrap in end for not blocking loops
	local baseCF = Part.CFrame -- This is a base cframe of part

	local Radius = 25 -- This is a radius of circle
	local Origin = baseCF + Vector3.new(0,Radius,0) -- This is a origin of circle

	local fromOrigin = CFrame.new(Origin.Position, baseCF.Position) -- This is a cframe that looks at basecf

	local lookVec, rightVec = fromOrigin.LookVector, fromOrigin.RightVector -- This is a lookvector and rightvector of cframe
	local circleCompletion = 0.01 -- This is a circle completion of circle

	local perAngle = 2*math.pi/circleCompletion -- This is a part of circle that will be completed every second
	local ST = tick() -- This is a tick that will be used for circle completion

	while task.wait() do -- This loop will be run every second
		local timeElapsed = tick()-ST -- This is a time elapsed since loop started
		local newPos = Origin.Position + lookVec*math.cos(perAngle*timeElapsed)*Radius + rightVec*math.sin(perAngle*timeElapsed)*Radius  -- This calculates a point on the circular path around the origin using sine and cosine to move along lookVector and rightVector    
		local newCF = CFrame.new(newPos, Origin.Position) -- This is a cframe that looks at origin and is at newpos

		Part.CFrame = newCF -- This makes part cframe to be a new cframe that looks at origin and is at newpos
	end

end


local function createDetectPart(player) -- Creates a part
	local Part = Instance.new("Part") --  That creates a part but we don't know where is it
	Part.Anchored = true -- Remove part physics and make it static
	Part.Size = Vector3.new(10,10,10) -- That changes part size to 10x10x10
	Part.CanCollide = false -- People can pass through part 
	Part.Transparency = 0.6 -- It makes part transparent but a bit(0.6)
	Part.Parent = Workspace -- It makes part to be a child of workspace
	Part.Name = player.Name .. "_DetectPart" -- It names part to player name and _DetectPart
	
end

local function removeDetectPart(player) -- Removes a part
	for _, part in Workspace:GetDescendants() do -- This loop gets all descendants of workspace
		if part:IsA("BasePart") and part.Name == player.Name then -- This checks if part is a basepart and if part name is player name
			game.Debris:AddItem(part, 0) -- This removes part
		end
	end
end

local function findpath() -- Finds path
	local Path = PathFinding:CreatePath({ -- This creates a path
		AgentCanJump = true, -- If npc can jump
	})

	local Way = Path:ComputeAsync(NpcHumanoidRootPart.Position, EndPos.Position) -- This computes path and returns path

	local WayPoints = Path:GetWaypoints() -- This gets waypoints from path and returns it
	
	for _, waypoint in WayPoints do -- This loop gets waypoints
		local Part = Instance.new("Part", workspace) -- Creates a part
		Part.Position = waypoint.Position -- This sets part position to waypoint position
		Part.Size = Vector3.new(1,1,1) -- This sets part size to 1x1x1
		Part.Anchored = true 
		Part.CanCollide = false 
	end
	
	for _, waypoint in WayPoints do -- This loop gets waypoints
		NpcHumanoid:MoveTo(waypoint.Position) -- This moves npc to waypoint position
		NpcHumanoid.MoveToFinished:Wait() -- This waits until npc reaches to waypoint
		
	end
end

local TWInfo = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0) -- TweenInfo for TweenService
local Properties = {CFrame = CFrame.new(0,35,0)} -- This table includes properties for TweenService
local Tween = TweenService:Create(DecalPart, TWInfo, Properties) -- This thing creates a tween first argument is instance, second is TweenInfo, third is properties(table)

local function teleportanotherworld(placeid,player) 
	TeleportService:Teleport(placeid, player) -- This teleports player to another game
end

TeleportPart.Touched:Connect(function(hit) -- This function is for when player touches teleport part
	local Character = hit.Parent or hit.Parent:Wait() -- This gets character
	local Player = Players:GetPlayerFromCharacter(Character) -- This gets player from character
	if Player then -- This checks if player exists
		teleportanotherworld(PLACE_ID, Player) -- This teleports player to another game first arg is PLACE_ID, second arg is player
	end
end)
 
local function givebadge(player, badgeid)
	BadgeService:AwardBadgeAsync(player.UserId, badgeid) -- This function gives badge working with id  
end

local function sendtochannel(player) -- Sends message to channel
	local data = { -- This table includes data for message
		["content"] = player.Name .. " has joined the game" -- This is message content
	}
	
	local json = HttpService:JSONEncode(data) -- This function encodes data to json
	
	local success, result = pcall(function() -- This function is for if message sent successfully
		HttpService:PostAsync(discurl, json) -- This function sends message
	end)
	
	if not success then -- This checks if message sent successfully
		warn("failed")
	end
end

local function giveuserdetail(plrsids) -- Gets user details
	local success, details = pcall(function() -- This function is for if user details got successfully
		return UserService:GetUserInfosByUserIdsAsync(plrsids) -- This function gets user details
	end)

	if success then
		for _, info in ipairs(details) do
			--print(info.DisplayName .. info.Username)
			--print(info.Id ..  info.Username)
			--print(info.Username)
			--print(info.HasVerifiedBadge)
		end
	end
end

local function buygamepass(player, gmpid) -- This function buys gamepass
	MarketPlaceService:PromptProductPurchase(player, gmpid, true) -- This function buys gamepass
end

local function groupinfo(id) -- This function gets group info
	local GroupInfo = GroupService:GetGroupInfoAsync(id) -- This function gets group info
	
	for _, roles in ipairs(GroupInfo.Roles) do -- This loop gets roles
		--print(roles.Name)
	end
end

local function groupemblem(id) -- This function gets group emblem
	local GroupInfo = GroupService:GetGroupInfoAsync(id) -- This function gets group info
	
	return GroupInfo.EmblemUrl -- This returns group emblem url
end 

local function load(player) -- This function is for when player joins
	local leaderstats = Instance.new("Folder") -- This creates folder for leaderstats
	leaderstats.Parent = player -- This makes folder parent player
	leaderstats.Name = "leaderstats" -- This renames folder to leaderstats

	local Cash = Instance.new("IntValue") -- This creates cash value
	Cash.Parent = leaderstats
	Cash.Name = "Cash"
	Cash.Value = 0 -- This sets cash to 0
	
	local DeletePart = Instance.new("Part") 
	DeletePart.Parent = workspace
	DeletePart.Name = "DeleteThatPart"
	DeletePart.CFrame = CFrame.new(0,15,0) -- This sets position of part
	DeletePart.Anchored = true
	
	local success, data = pcall(function() -- This function is for if player data loaded successfully
		return MainData:GetAsync(player.UserId) -- This function loads player data
	end)
	
	if success and data then -- This checks if player data loaded successfully
		player.leaderstats.Cash.Value = data -- This sets cash to player data
	end
	
	-- FUNCTIONS i put them to game.players.playeradded because when a player joined these functions will be work
	createDetectPart(player)
	groupinfo(groupId)
	GroupDecal.ColorMapContent = Content.fromUri(groupemblem(groupId))
	buygamepass(player, gamepassid)
	Tween:Play()
	game.Debris:AddItem(DeletePart, 10)
	giveuserdetail(playerids)
	sendtochannel(player)
	givebadge(player, BADGE_ID)
	findpath()
end

local function save(player) -- This function is for when player leaves
	local success, fail = pcall(function() -- This function is for if player data saved successfully
		MainData:SetAsync(player.UserId, player.leaderstats.Cash.Value) -- This function saves player data
	end)
	
	if success then -- This checks if player data saved successfully 	
		print("Saved " .. player.Name .. " Data")
		removeDetectPart(player)
	elseif fail then -- This checks if player data not saved successfully
		print("Not Saved")
	end
end

game.Players.PlayerRemoving:Connect(save) -- This function is for when player leaves
game.Players.PlayerAdded:Connect(load) -- This function is for when player joins

game:BindToClose(function() -- This function is for when game closed
	for _, plrs in Players:GetPlayers() do -- This loop is for all players in game
		MainData:SetAsync(plrs.UserId, plrs.leaderstats.Cash.Value) -- This function saves player data
		removeDetectPart(plrs) -- This function removes detect part
	end
end)

if RunService:IsStudio() then -- This checks if game is testing in studio
	--print("This game is testing in studio") 
end

RunService.Heartbeat:Connect(function(deltaTime) -- that arg gives us to frame to frame time
	local FramePerSecond = math.floor(1/ deltaTime) -- Thats give you your frame per second(FPS)
	--print(FramePerSecond)
	for _, player in Players:GetPlayers() do -- This loop is for all players in game 
		local character = player.Character or player.CharacterAdded:Wait() -- This gets player character
		local DetectPart = Workspace:WaitForChild(player.Name .. "_DetectPart") -- This gets detect part
		if character then -- Control
			local Head = character:WaitForChild("Head")
			if Head then -- Control
				local RayOrigin = Head.Position -- This gets head position where ray will start
				local RayDirection = Head.CFrame.LookVector * 25  -- This gets head lookvector and multiply it to 25
				DetectPart.CFrame = CFrame.new(RayOrigin + RayDirection) -- This sets detect part CFrame
				
				local TouchParts = Workspace:GetPartsInPart(DetectPart) -- This gets all parts in detect part
				
				for _, parts in TouchParts do -- This loop is for all parts in detect part
					if parts.Parent == character then return end -- This checks if touched part is player character
					if not parts:IsDescendantOf(Workspace.IgnoreThatParts) then -- Checks are parts is child of workspace ignorethatparts   
						print(parts.Name)
					end
				end
			end
		end
	end	
end)

coroutine.wrap(turnpartmath(Part))
