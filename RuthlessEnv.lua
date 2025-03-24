local Library = {}

Library.OnDataString = nil
Library.OnDataTable = nil

local indexTable = {
	["A"] = "1023", ["B"] = "4067", ["C"] = "8392", ["D"] = "9173", ["E"] = "2840",
	["F"] = "6701", ["G"] = "9324", ["H"] = "8076", ["I"] = "3642", ["J"] = "9012",
	["K"] = "6738", ["L"] = "2401", ["M"] = "8042", ["N"] = "1637", ["O"] = "7204",
	["P"] = "9083", ["Q"] = "4370", ["R"] = "2648", ["S"] = "3702", ["T"] = "4091",
	["U"] = "8034", ["V"] = "2067", ["W"] = "9473", ["X"] = "6124", ["Y"] = "8340",
	["Z"] = "7093", ["a"] = "3412", ["b"] = "9084", ["c"] = "2736", ["d"] = "7041",
	["e"] = "6328", ["f"] = "4072", ["g"] = "9360", ["h"] = "2184", ["i"] = "7043",
	["j"] = "9812", ["k"] = "3647", ["l"] = "2403", ["m"] = "8720", ["n"] = "4612",
	["o"] = "7930", ["p"] = "6042", ["q"] = "8317", ["r"] = "2904", ["s"] = "8740",
	["t"] = "3026", ["u"] = "6704", ["v"] = "9132", ["w"] = "4620", ["x"] = "8024",
	["y"] = "3740", ["z"] = "6920", ["0"] = "2468", ["1"] = "1937", ["2"] = "8023",
	["3"] = "7604", ["4"] = "3092", ["5"] = "9183", ["6"] = "4703", ["7"] = "9204",
	["8"] = "3170", ["9"] = "8642", ["!"] = "3074", ["@"] = "6192", ["#"] = "7408",
	["$"] = "2307", ["%"] = "8940", ["^"] = "6720", ["&"] = "1304", ["*"] = "9072",
	["("] = "3824", [")"] = "6048", ["-"] = "9412", ["_"] = "7083", ["="] = "4632",
	["+"] = "8027", ["["] = "7013", ["]"] = "6240", ["{"] = "7392", ["}"] = "8704",
	[";"] = "2340", [":"] = "9043", ["'"] = "6812", ['"'] = "2930", [","] = "7402",
	["."] = "9184", ["/"] = "3640", ["?"] = "2740", ["<"] = "3902", [">"] = "7406",
	["|"] = "6023", ["\\"] = "8072", [" "] = "1111"
}

local reverseTable = {}
for char, code in pairs(indexTable) do
	reverseTable[code] = char
end

local function encodeString(input)
	local encoded = {}
	for i = 1, #input do
		local char = input:sub(i, i)
		table.insert(encoded, indexTable[char] or "0000")
	end
	return table.concat(encoded, "999")
end

local function decodeString(input)
	local decoded = {}
	for _, code in ipairs(string.split(input, "999")) do
		table.insert(decoded, reverseTable[code] or "?")
	end
	return table.concat(decoded)
end

local function encodeTable(tbl)
	local encoded = {}
	for index, value in pairs(tbl) do
		local encodedIndex = "444" .. encodeString(tostring(index)) .. "444"
		local encodedValue = "888" .. encodeString(tostring(value)) .. "888"
		table.insert(encoded, encodedIndex .. encodedValue)
	end
	return table.concat(encoded, "999")
end

local function decodeTable(input)
	local decoded = {}
	for encodedIndex, encodedValue in input:gmatch("444(.-)444888(.-)888") do
		local index = decodeString(encodedIndex)
		local value = decodeString(encodedValue)
		decoded[tonumber(index) or index] = value
	end
	return decoded
end
local function CheckForData(player, character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.AnimationPlayed:Connect(function(track)
            local animId = track.Animation.AnimationId:gsub("rbxassetid://", "")
            if not animId:match("https://www.roblox") then
                local success, result = pcall(function()
                    local decodedData = decodeTable(animId)
                    if Library.OnDataTable then
                        Library.OnDataTable(player, decodedData)
                    end
                end)
                print(result)
                local success, result = pcall(function()
                    local decodedData = decodeString(animId)
                    if Library.OnDataString then
                        Library.OnDataString(player, decodedData)
                    end
                end)
                print(result)
            end
        end)
    end
end

function Library.FireData(Data)
    local function SendDataTable()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. encodeTable(Data)
        game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid"):LoadAnimation(anim):Play()
    end
    local function SendDataString()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. encodeString(Data)
        game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid"):LoadAnimation(anim):Play()
    end
    if typeof(Data) == "table" then
        local success, result = pcall(SendDataTable)
        print(result)
    elseif typeof(Data) == "string" then
        local success, result = pcall(SendDataString)
        print(result)
    else
        warn("You can send only string or table data!")
    end
end

function Library.Start()
    local function onPlayerAdded(player)
        player.CharacterAdded:Connect(function(character) CheckForData(player, character) end)
        if player.Character then CheckForData(player, player.Character) end
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
    for _, player in Players:GetPlayers() do 
        onPlayerAdded(player) 
    end
end


function Library.DownloadFromGitHub(GithubSnd, SoundName)
    local fileName = "_RuthlessLibrary_Git_" .. tostring(SoundName) .. ".mp3"

    if not isfile(fileName) then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Downloading File",
            Text = "Downloading " .. SoundName .. "...",
            Duration = 3
        })
        
        local success, result = pcall(function()
            return game:HttpGet(GithubSnd)
        end)
        
        if success then
            writefile(fileName, result)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Download Complete",
                Text = SoundName .. " downloaded successfully!",
                Duration = 3
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Download Failed",
                Text = "Failed to download " .. SoundName,
                Duration = 5
            })
            return nil
        end
    end

    return (getcustomasset or getsynasset)(fileName)
end

function Library.DownloadFromDiscord(fileName, link)
    local function wf(st, a)
        if not isfile(st) then
            local y = a
            if string.find(a, "https://www.mediafire") or string.find(a, "https://cdn.discordapp.com/attachments/") then
                local request = request or syn.request
                local response = request({Url = a, Method = "GET"})
                local url = response.Body
                if not string.find(a, "https://cdn.discordapp.com/attachments") then
                    local split = string.split(url, "https://download")[2]
                    for i = 1, string.len(split) do
                        local yes = string.sub(split, i, i)
                        if string.find(yes, '"') then
                            y = "https://download" .. string.sub(split, 1, i - 1)
                            break
                        end
                    end
                    writefile(st, game:HttpGet(y))
                else
                    writefile(st, response.Body)
                end
            else
                error("Invalid link, Mediafire or discord attachment links only")
            end
        end
        local getasset = getsynasset or getcustomasset
        return getasset(st)
    end
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Downloading File",
        Text = "Downloading " .. fileName .. "...",
        Duration = 3
    })
    repeat
        wait()
    until wf(fileName, link)
    return (getcustomasset or getsynasset)(fileName)
end

function Library.ListAllRemotes()
    local remotes = {}
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(remotes, obj:GetFullName())
        end
    end
    return remotes
end

return Library
