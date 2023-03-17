local Key = "Period"

-- getgenv().destructive = true			     For developers, disabled to allow loadstring + editing.
-- Set to "true" if you want to include players in your farm

-- getgenv().weapon = "Strong Silent Blades"         For developers, disabled to allow loadstring + editing.
--[[
	Set the above to your weapon.
	Must be case-sensitive including the enchantment.
	for ex: Strong Silent Blades
	ex2: Swift Scimitars of Storm
]]--

getgenv().farmbounty = false

local plr = Game:GetService("Players").LocalPlayer.Character.HumanoidRootPart

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function fmtName(str)
	if str:find("MC", 1, true) == 1 then
		local new_str = split(str:lower(), "mc")
		return ("Mc"..new_str[2]:gsub("^%l", string.upper))
	else
    	return (str:lower():gsub("^%l", string.upper))
    end
end

function isPlayer(check)
	if check:find("Level", 1, true) == 1 and split(check:lower(), " ")[1] == "level" then
		return false
	else
		return true
	end
end

function Toaster(title, text)
	game.StarterGui:SetCore("SendNotification", {
		Title = title;
		Text = text; 
		Icon = "rbxassetid://57254792";
		Duration = 5;
	})
end




function getBounty()
	repeat task.wait() plr.CFrame = CFrame.new(12772, 437, 2179) until game:GetService("Workspace").Map["Sailor's Lodge"]:FindFirstChild("Spawns") and game:GetService("Workspace").Map["Sailor's Lodge"].Artificial:FindFirstChild("BountyBoard")
	plr.CFrame = CFrame.new(12772, 437, 2179) -- ReTP's you so it doesn't fling you when the map loads and you stop floating.
	wait(0.5)
	
	local virtualUser = game:GetService('VirtualUser')
	virtualUser:CaptureController()
	virtualUser:SetKeyDown('0x65')
	wait(0.3)
	virtualUser:SetKeyUp('0x65')
	wait(1)
	
	local list = game:GetService("Players").LocalPlayer.PlayerGui.RenownBoardGui.Frame.Server.List.Frame
	local bounty = "None"
	local plrName = nil
	for i, picks in pairs(list:GetChildren()) do
		pcall(function()
			local checkEnemy = fmtName(list:FindFirstChild(picks.Name).Poster.Criminal.Text)
			local isEnemy = game.Workspace.Enemies:FindFirstChild(checkEnemy)
			if isPlayer(list:FindFirstChild(picks.Name).Poster.CriminalPlr.Text) == true and getgenv().destructive == true then
				bounty = picks.Name
				plrName = list:FindFirstChild(picks.Name).Poster.CriminalPlr.Text
			elseif isPlayer(list:FindFirstChild(picks.Name).Poster.CriminalPlr.Text) == true and getgenv().destructive == false then
				Toaster(checkEnemy.." is a player.", checkEnemy.." is a player and you disabled destructive mode so we will skip this bounty...")
			elseif isEnemy and isEnemy:FindFirstChild("Jailed") or isEnemy and isEnemy:FindFirstChild("JailMark") or isEnemy and isEnemy.Humanoid.Health <= 0 then
			   	--Toaster(checkEnemy.." is not on the map.", checkEnemy.." is either already dead, jailed, or not on the map.\n Going next...")
			   	--removing for clarity
			else
			   	bounty = picks.Name
			end
		end)
	end
	if list:FindFirstChild(bounty) then
		local crm = fmtName(list:FindFirstChild(bounty).Poster.Criminal.Text)
		local bty = tostring(tonumber((string.gsub(list:FindFirstChild(bounty).Poster.Bounty.Text, ",", ""))))
		local args = {
	    [1] = crm.."_"..bty,
	    [2] = crm,
	    [3] = "Bounty"
		}
		
		game:GetService("ReplicatedStorage"):WaitForChild("RS"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("HuntPlayer"):InvokeServer(unpack(args))
		plr.CFrame = CFrame.new(12803, 440, 2181) --TP to destroy BountyBoard UI just in case it hasn't updated
		wait(1)
		
		if plrName == nil then
			return crm
		else
			return plrName
		end
	else
		return nil
	end
end

function attackFoe(isEnemy)
	if isEnemy and isEnemy.Humanoid.Health > 0 and not isEnemy:FindFirstChild("Jailed") and not isEnemy:FindFirstChild("JailMark") then
		repeat
			wait()
			plr.CFrame = isEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
														
			local args = {
				[1] = game:GetService("Players").LocalPlayer.Character:FindFirstChild(getgenv().weapon),
				[3] = Vector3.new(15796.8896484375, 419.4910888671875, 2676.74755859375)
			}
													
			game:GetService("ReplicatedStorage"):WaitForChild("RS"):WaitForChild("Remotes"):WaitForChild("Combat"):WaitForChild("UseWeapon"):FireServer(unpack(args))
											
		until isEnemy.Humanoid.Health <= 0 or getgenv().farmbounty == false
	end
end

function gotoBounty()
	local pk = false
	local crm = getBounty()
	if getgenv().destructive == true and Game:GetService("Players"):FindFirstChild(crm) then
		pk = true
	elseif game.Workspace.Enemies:FindFirstChild(crm) then
		Toaster(crm.." is active!", crm.." is already loaded, will try to steal the kill if possible.")
	else
		local t = game.ReplicatedStorage.RS.UnloadEnemies:FindFirstChild(crm)
		repeat task.wait() plr.CFrame = t.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) + Vector3.new(0, 5, 0) until game.Workspace.Enemies:FindFirstChild(crm)
	end
	
	if pk == false then
		local isEnemy = game.Workspace.Enemies:FindFirstChild(crm)
		attackFoe(isEnemy)
	else
		local isEnemy = game.Workspace:FindFirstChild(crm)
		attackFoe(isEnemy)
	end
end


game:GetService("UserInputService").InputBegan:Connect(function(keyobject, stuffhappening)
    if keyobject.KeyCode == Enum.KeyCode[Key] and not stuffhappening then 
        getgenv().farmbounty = not getgenv().farmbounty
		if getgenv().farmbounty == true then
			Toaster("Farm enabled", 'The farm is turned on. Press "." to turn off.')
		else
			Toaster("Farm disabled", 'The farm is turned off. Press "." to turn it on again.')
		end
    end
end)


coroutine.wrap(function()
    while wait() do
        if getgenv().farmbounty == true then
			pcall(function()
				gotoBounty()
				wait(0.5)
            end)
        end
    end
end)()

Toaster("Fame Farm Script", "Created by RedPhantom")
