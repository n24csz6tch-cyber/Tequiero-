--[[
=====================================================================
   🦖 VENICE HUB  •  Prehistoric Farm  •  v4.0
   Place: 139780970631001   |   UI 100% propia (sin Rayfield)
   Reescrito desde 0 — detección real de dig-sites por ProximityPrompt
=====================================================================
]]

local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local RS         = game:GetService("ReplicatedStorage")
local TS         = game:GetService("TweenService")
local LIGHT      = game:GetService("Lighting")
local LP         = Players.LocalPlayer

--========================= PALETA =========================
local ACCENT  = Color3.fromRGB(0, 214, 158)
local ACCENT2 = Color3.fromRGB(255, 168, 66)
local BG      = Color3.fromRGB(18, 20, 26)
local ROWC    = Color3.fromRGB(32, 35, 43)
local TXT     = Color3.fromRGB(236, 239, 245)
local SUB     = Color3.fromRGB(150, 158, 172)
local RED     = Color3.fromRGB(240, 90, 90)

--========================= HELPERS =========================
local function mk(c, p, par)
    local o = Instance.new(c)
    if p then for k, v in pairs(p) do o[k] = v end end
    if par then o.Parent = par end
    return o
end
local function corner(o, r) mk("UICorner", { CornerRadius = UDim2.new(0, r or 8, 0, r or 8) }, o) end
local function stroke(o, col, th, tr)
    mk("UIStroke", { Color = col or Color3.fromRGB(64, 70, 84), Thickness = th or 1, Transparency = tr or 0.35 }, o)
end
local function hrp() local c = LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c = LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end

local S = {
    speed = 16, jump = 50, infjump = false, fly = false, noclip = false,
    walkWater = false, follow = false,
    espPlayers = false, espDinos = false, espDig = false,
    autodig = false, tpdig = true, magnet = false,
    autoprompt = false, radius = 45, forceprompt = false, instanthold = false,
    autoMoney = false, autoSell = false, loopRemote = false, remoteLog = true,
    antiVoid = false, antiAfk = false,
}

--========================= GUI BASE =========================
local parentGui = (gethui and gethui()) or game:GetService("CoreGui")
local gui = mk("ScreenGui", {
    Name = "VenicePFHub", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
}, parentGui)

local main = mk("Frame", {
    Name = "Main", Size = UDim2.new(0, 660, 0, 420),
    Position = UDim2.new(0.5, -330, 0.5, -210),
    BackgroundColor3 = BG, BorderSizePixel = 0, ClipsDescendants = true,
}, gui)
corner(main, 16); stroke(main, Color3.fromRGB(70, 78, 95), 1.5)

-- fondo (miniatura real del juego)
local bgImg = mk("ImageLabel", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
    Image = "rbxthumb://type=GameIcon&id=139780970631001&w=720&h=720",
    ScaleType = Enum.ScaleType.Crop, ImageTransparency = 0.55, ZIndex = 1,
}, main)
corner(bgImg, 16)
mk("UIGradient", {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 10, 16)),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(1, 0.35),
    }),
}, bgImg)

-- barra superior
local top = mk("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1, ZIndex = 3 }, main)
mk("TextLabel", {
    Text = "🦖 VENICE HUB", Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = TXT,
    TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 7), Size = UDim2.new(0, 300, 0, 22),
}, top)
mk("TextLabel", {
    Text = "Prehistoric Farm  •  v4.0  •  custom UI", Font = Enum.Font.Gotham, TextSize = 12,
    TextColor3 = SUB, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 26), Size = UDim2.new(0, 320, 0, 16),
}, top)

local function winBtn(txt, x, cb)
    local b = mk("TextButton", {
        Text = txt, Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = SUB,
        BackgroundColor3 = Color3.fromRGB(40, 44, 53), BackgroundTransparency = 0.2,
        Position = UDim2.new(1, x, 0, 12), Size = UDim2.new(0, 26, 0, 26),
        TextXAlignment = Enum.TextXAlignment.Center, AutoButtonColor = false, BorderSizePixel = 0,
    }, top)
    corner(b, 13)
    b.MouseButton1Click:Connect(cb)
    return b
end
local float = mk("TextButton", {
    Text = "🦖", Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = TXT,
    BackgroundColor3 = BG, Size = UDim2.new(0, 46, 0, 46),
    Position = UDim2.new(0, 16, 0, 16), Visible = false, BorderSizePixel = 0,
}, gui)
corner(float, 23); stroke(float, ACCENT, 1.5)
float.MouseButton1Click:Connect(function() main.Visible = true; float.Visible = false end)

winBtn("—", -68, function() main.Visible = false; float.Visible = true end)
winBtn("✕", -36, function() gui:Destroy() end)

-- arrastrar
do
    local drag, sp, sm
    top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag, sp, sm = true, main.Position, i.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - sm
            main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
end

--========================= NOTIFICACIONES =========================
local nh = mk("Frame", { Size = UDim2.new(0, 280, 0, 400), Position = UDim2.new(1, -296, 0, 18), BackgroundTransparency = 1, ZIndex = 100 }, gui)
mk("UIListLayout", { Padding = UDim2.new(0, 8, 0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Right }, nh)

local function notify(title, content, col)
    local card = mk("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Color3.fromRGB(28, 31, 38), BackgroundTransparency = 0.05 }, nh)
    corner(card, 10); stroke(card, col or ACCENT, 1, 0.2)
    mk("Frame", { Size = UDim2.new(0, 3, 1, -12), Position = UDim2.new(0, 0, 0, 6), BackgroundColor3 = col or ACCENT, BorderSizePixel = 0 }, card)
    mk("TextLabel", { Text = title, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = TXT, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 6), Size = UDim2.new(1, -16, 0, 16) }, card)
    mk("TextLabel", { Text = content or "", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = SUB, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 23), Size = UDim2.new(1, -16, 0, 24) }, card)
    task.delay(4, function()
        if card.Parent then
            local t = TS:Create(card, TweenInfo.new(0.35), { BackgroundTransparency = 1 })
            t:Play(); t.Completed:Wait(); card:Destroy()
        end
    end)
end

--========================= SIDEBAR / TABS =========================
local sidebar = mk("Frame", {
    Size = UDim2.new(0, 152, 1, -62), Position = UDim2.new(0, 8, 0, 54),
    BackgroundColor3 = Color3.fromRGB(24, 27, 34), BackgroundTransparency = 0.12,
    BorderSizePixel = 0, ZIndex = 3,
}, main)
corner(sidebar, 12)
local tabList = mk("Frame", { Size = UDim2.new(1, -8, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundTransparency = 1 }, sidebar)
mk("UIListLayout", { Padding = UDim2.new(0, 4, 0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, tabList)

local content = mk("Frame", {
    Size = UDim2.new(1, -176, 1, -62), Position = UDim2.new(0, 168, 0, 54),
    BackgroundTransparency = 1, ZIndex = 3,
}, main)

local pages, ActivePage = {}, nil
local function makeTab(name, order)
    local btn = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = order,
    }, tabList)
    corner(btn, 8)
    local lbl = mk("TextLabel", {
        Text = name, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = SUB,
        TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -12, 1, 0), BackgroundTransparency = 1,
    }, btn)
    local bar = mk("Frame", { Size = UDim2.new(0, 3, 0, 16), Position = UDim2.new(0, 0, 0.5, -8), BackgroundColor3 = ACCENT, Visible = false, BorderSizePixel = 0 }, btn)
    corner(bar, 2)
    local page = mk("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 4,
        ScrollBarImageColor3 = ACCENT, CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
    }, content)
    mk("UIListLayout", { Padding = UDim2.new(0, 6, 0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, page)
    pages[name] = page

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        for _, c in ipairs(tabList:GetChildren()) do
            if c:IsA("TextButton") then
                c.BackgroundTransparency = 1
                c:FindFirstChildOfClass("TextLabel").TextColor3 = SUB
                c:FindFirstChildOfClass("Frame").Visible = false
            end
        end
        page.Visible = true
        btn.BackgroundTransparency = 0.88
        lbl.TextColor3 = TXT
        bar.Visible = true
        ActivePage = page
    end)
    return page
end

--========================= COMPONENTES =========================
local order = 0
local function nextOrder() order = order + 1; return order end

local function addSection(text)
    local f = mk("Frame", { Size = UDim2.new(1, -6, 0, 24), BackgroundTransparency = 1, LayoutOrder = nextOrder() }, ActivePage)
    mk("TextLabel", { Text = text:upper(), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = ACCENT, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Position = UDim2.new(0, 4, 0, 0), Size = UDim2.new(1, -8, 1, 0) }, f)
end

local function addLabel(text, col)
    mk("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = col or SUB,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(),
    }, ActivePage)
end

local function addButton(name, cb)
    local r = mk("Frame", { Size = UDim2.new(1, -8, 0, 34), BackgroundColor3 = ROWC, BackgroundTransparency = 0.15, BorderSizePixel = 0, LayoutOrder = nextOrder() }, ActivePage)
    corner(r, 8)
    local b = mk("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, r)
    mk("TextLabel", { Text = name, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = TXT, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -24, 1, 0), BackgroundTransparency = 1 }, r)
    b.MouseEnter:Connect(function() TS:Create(r, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(46, 50, 60) }):Play() end)
    b.MouseLeave:Connect(function() TS:Create(r, TweenInfo.new(0.12), { BackgroundColor3 = ROWC }):Play() end)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
    return r
end

local function addToggle(name, flag, default, cb)
    local r = mk("Frame", { Size = UDim2.new(1, -8, 0, 36), BackgroundColor3 = ROWC, BackgroundTransparency = 0.15, BorderSizePixel = 0, LayoutOrder = nextOrder() }, ActivePage)
    corner(r, 8)
    mk("TextLabel", { Text = name, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = TXT, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -70, 1, 0), BackgroundTransparency = 1 }, r)
    local pill = mk("Frame", { Size = UDim2.new(0, 42, 0, 22), Position = UDim2.new(1, -52, 0.5, -11), BackgroundColor3 = Color3.fromRGB(60, 66, 80), BorderSizePixel = 0 }, r)
    corner(pill, 11)
    local knob = mk("Frame", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = Color3.fromRGB(220, 224, 232), BorderSizePixel = 0 }, pill)
    corner(knob, 9)
    local state = default and true or false
    S[flag] = state
    local function render(anim)
        local goal = state and UDim2.new(0, 22, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        local col = state and ACCENT or Color3.fromRGB(60, 66, 80)
        if anim then
            TS:Create(knob, TweenInfo.new(0.15), { Position = goal }):Play()
            TS:Create(pill, TweenInfo.new(0.15), { BackgroundColor3 = col }):Play()
        else
            knob.Position = goal; pill.BackgroundColor3 = col
        end
    end
    render(false)
    local b = mk("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, r)
    b.MouseButton1Click:Connect(function()
        state = not state; render(true); S[flag] = state
        if cb then cb(state) end
    end)
end

local function addSlider(name, min, max, default, flag, cb)
    local r = mk("Frame", { Size = UDim2.new(1, -8, 0, 52), BackgroundColor3 = ROWC, BackgroundTransparency = 0.15, BorderSizePixel = 0, LayoutOrder = nextOrder() }, ActivePage)
    corner(r, 8)
    mk("TextLabel", { Text = name, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = TXT, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0, 12, 0, 6), Size = UDim2.new(1, -80, 0, 16), BackgroundTransparency = 1 }, r)
    local val = mk("TextLabel", { Text = tostring(default), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = ACCENT, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(1, -72, 0, 6), Size = UDim2.new(0, 60, 0, 16), BackgroundTransparency = 1 }, r)
    local track = mk("Frame", { Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 0, 34), BackgroundColor3 = Color3.fromRGB(58, 63, 76), BorderSizePixel = 0 }, r)
    corner(track, 3)
    local fill = mk("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = ACCENT, BorderSizePixel = 0 }, track)
    corner(fill, 3)
    local knob = mk("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, -7, 0.5, -7), BackgroundColor3 = Color3.fromRGB(240, 242, 248), BorderSizePixel = 0, ZIndex = 2 }, track)
    corner(knob, 7)
    local function setv(v, fire)
        v = math.clamp(v, min, max)
        local a = (v - min) / (max - min)
        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, -7, 0.5, -7)
        val.Text = (v % 1 == 0) and tostring(math.floor(v)) or string.format("%.1f", v)
        S[flag] = v
        if fire and cb then cb(v) end
    end
    setv(default, false)
    local drag = false
    local function upd(i)
        local a = (i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
        setv(min + (max - min) * math.clamp(a, 0, 1), true)
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; upd(i) end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
end

local function addDropdown(name, options, cb)
    local base = 34
    local holder = mk("Frame", { Size = UDim2.new(1, -8, 0, base), BackgroundColor3 = ROWC, BackgroundTransparency = 0.15, BorderSizePixel = 0, LayoutOrder = nextOrder() }, ActivePage)
    corner(holder, 8)
    local head = mk("TextButton", { Size = UDim2.new(1, 0, 0, base), BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, holder)
    local lbl = mk("TextLabel", { Text = name, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = TXT, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -40, 0, base), BackgroundTransparency = 1 }, holder)
    mk("TextLabel", { Text = "▾", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = SUB, Position = UDim2.new(1, -28, 0, 0), Size = UDim2.new(0, 20, 0, base), BackgroundTransparency = 1 }, holder)
    local list = mk("Frame", { Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, base), BackgroundTransparency = 1, ClipsDescendants = true }, holder)
    mk("UIListLayout", { Padding = UDim2.new(0, 3, 0, 3) }, list)
    local open = false
    for _, opt in ipairs(options) do
        local b = mk("TextButton", { Size = UDim2.new(1, -12, 0, 26), BackgroundColor3 = Color3.fromRGB(44, 48, 58), Text = opt, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TXT, BorderSizePixel = 0, AutoButtonColor = false }, list)
        corner(b, 6)
        b.MouseButton1Click:Connect(function()
            lbl.Text = name .. "  ·  " .. opt
            open = false; list.Size = UDim2.new(1, 0, 0, 0); holder.Size = UDim2.new(1, -8, 0, base)
            if cb then cb(opt) end
        end)
    end
    head.MouseButton1Click:Connect(function()
        open = not open
        local h = open and (#options * 29) or 0
        list.Size = UDim2.new(1, 0, 0, h)
        holder.Size = UDim2.new(1, -8, 0, base + h)
    end)
end

local function addInput(name, placeholder, cb)
    local r = mk("Frame", { Size = UDim2.new(1, -8, 0, 36), BackgroundColor3 = ROWC, BackgroundTransparency = 0.15, BorderSizePixel = 0, LayoutOrder = nextOrder() }, ActivePage)
    corner(r, 8)
    mk("TextLabel", { Text = name, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = TXT, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0.5, -12, 1, 0), BackgroundTransparency = 1 }, r)
    local box = mk("TextBox", {
        Text = "", PlaceholderText = placeholder or "", PlaceholderColor3 = SUB,
        Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TXT, ClearTextOnFocus = false,
        BackgroundColor3 = Color3.fromRGB(46, 50, 60), BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, -11), Size = UDim2.new(0.5, -12, 0, 22),
    }, r)
    corner(box, 6)
    box.FocusLost:Connect(function() if cb then cb(box.Text) end end)
    return box
end

--========================= TABS =========================
makeTab("Inicio", 1)
makeTab("Movimiento", 2)
makeTab("Visuales", 3)
makeTab("Spots", 4)
makeTab("Granja", 5)
makeTab("Bypass", 6)
makeTab("Dinero", 7)
makeTab("Jugador", 8)
makeTab("Extras", 9)

--========================= DETECCIÓN DIG-SITES =========================
local DIG_KW = { "dig", "excav", "mound", "fossil", "buried", "bone" }
local function kwm(s)
    s = (s or ""):lower()
    for _, k in ipairs(DIG_KW) do if s:find(k, 1, true) then return true end end
    return false
end

local promptCache = {}
task.spawn(function()
    while true do
        local t = {}
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("ProximityPrompt") then t[#t + 1] = d end
        end
        promptCache = t
        task.wait(2)
    end
end)

-- devuelve partes que SÍ son dig-sites (prompt con texto dig o nombre clave)
local function findDigSites()
    local out, seen = {}, {}
    for _, p in ipairs(promptCache) do
        if kwm(p.ActionText) or kwm(p.ObjectText) then
            local part = p.Parent
            if part and part:IsA("BasePart") and not seen[part] then
                seen[part] = true; out[#out + 1] = part
            end
        end
    end
    if #out > 0 then return out end
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("BasePart") and kwm(d.Name) then out[#out + 1] = d end
    end
    return out
end

local function digPromptOf(part)
    local pr = part:FindFirstChildWhichIsA("ProximityPrompt", true)
    if pr and (kwm(pr.ActionText) or kwm(pr.ObjectText)) then return pr end
    return pr
end

--========================= FIRE PROMPT =========================
local firePrompt
if fireproximityprompt then
    firePrompt = function(p) pcall(fireproximityprompt, p) end
else
    firePrompt = function(p)
        pcall(function()
            p:InputHoldBegin(); task.wait(math.max(p.HoldDuration, 0.05)); p:InputHoldEnd()
        end)
    end
end

--========================= INICIO =========================
ActivePage = pages["Inicio"]
addSection("Guía")
addLabel("1) Dinero → Detectar remote.  2) Pulsa FARM COMPLETO.  3) Activa Auto Cavar en Granja.")
addLabel("Detección de montículos por texto del ProximityPrompt (Dig/Excavate), ya no detecta cosas falsas.")
addSection("Acciones")
addButton("⚡ FARM COMPLETO (todo ON)", function()
    S.autodig = true; S.tpdig = true; S.forceprompt = true; S.instanthold = true
    S.autoprompt = true; S.autoMoney = true; S.autoSell = true
    notify("Farm", "Auto Cavar + Bypass + Auto Dinero/Venta ON", ACCENT2)
end)
addButton("🧲 IMÁN + AUTO DESENTERRAR", function()
    S.magnet = true; S.autodig = true; S.instanthold = true
    notify("Imán", "Montículos traídos + auto excavado", ACCENT2)
end)
addSection("Servidor")
addButton("Rejoin", function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end)
addButton("Ver stats (consola)", function()
    local ls = LP:FindFirstChild("leaderstats")
    if ls then for _, v in ipairs(ls:GetChildren()) do print("STAT:", v.Name, "=", v.Value) end end
    notify("Stats", "Impreso en consola")
end)

--========================= MOVIMIENTO =========================
ActivePage = pages["Movimiento"]
addSection("Velocidad")
addSlider("Velocidad", 16, 1000, 16, "speed", function(v) local h = hum(); if h then h.WalkSpeed = v end end)
addSlider("Salto", 50, 1000, 50, "jump", function(v) local h = hum(); if h then h.UseJumpPower = true; h.JumpPower = v end end)
addToggle("Salto infinito", "infjump", false)
UIS.JumpRequest:Connect(function()
    if S.infjump then local h = hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)
addSection("Vuelo / Noclip")
local flyConn
addToggle("Volar (WASD + Espacio/Ctrl)", "fly", false, function(v)
    if v then
        local _, root = hum(), hrp()
        if not root then return end
        local bv = mk("BodyVelocity", { MaxForce = Vector3.new(1e5, 1e5, 1e5), Velocity = Vector3.zero, Parent = root })
        local keys = {}
        if flyConn then flyConn:Disconnect() end
        flyConn = RunService.RenderStepped:Connect(function()
            if not S.fly or not root.Parent then bv:Destroy(); if flyConn then flyConn:Disconnect() end; return end
            local cam = workspace.CurrentCamera.CFrame
            local m = Vector3.zero
            if keys[Enum.KeyCode.W] then m += cam.LookVector end
            if keys[Enum.KeyCode.S] then m -= cam.LookVector end
            if keys[Enum.KeyCode.A] then m -= cam.RightVector end
            if keys[Enum.KeyCode.D] then m += cam.RightVector end
            if keys[Enum.KeyCode.Space] then m += Vector3.new(0, 1, 0) end
            if keys[Enum.KeyCode.LeftControl] then m -= Vector3.new(0, 1, 0) end
            bv.Velocity = m.Magnitude > 0 and m.Unit * 80 or Vector3.zero
        end)
        UIS.InputBegan:Connect(function(i, g) if not g then keys[i.KeyCode] = true end end)
        UIS.InputEnded:Connect(function(i) keys[i.KeyCode] = false end)
    end
end)
addToggle("Noclip", "noclip", false)
RunService.Stepped:Connect(function()
    if S.noclip and LP.Character then
        for _, p in ipairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end
end)
addSection("Transporte")
addButton("Teleport al cursor (Click TP)", function()
    local m = UIS:GetMouseLocation()
    local ray = workspace.CurrentCamera:ViewportPointToRay(m.X, m.Y)
    local par = RaycastParams.new(); par.FilterDescendantsInstances = { LP.Character }
    local res = workspace:Raycast(ray.Origin, ray.Direction * 4000, par)
    if res then local r = hrp(); if r then r.CFrame = CFrame.new(res.Position + Vector3.new(0, 4, 0)) end end
end)
addToggle("Seguir jugador más cercano", "follow", false)
task.spawn(function()
    while true do task.wait(0.15)
        if S.follow then
            local r = hrp(); local best, bd
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local o = p.Character:FindFirstChild("HumanoidRootPart")
                    if o then local d = (o.Position - r.Position).Magnitude; if not bd or d < bd then best, bd = o, d end end
                end
            end
            if best and r then r.CFrame = best.CFrame * CFrame.new(0, 0, 6) end
        end
    end
end)
addSection("Agua (arreglado)")
addToggle("Caminar sobre el agua/superficie", "walkWater", false)
task.spawn(function()
    while true do task.wait(0.1)
        if S.walkWater and not S.fly then
            local r = hrp()
            if r then
                local par = RaycastParams.new(); par.FilterDescendantsInstances = { LP.Character }; par.IgnoreWater = false
                local res = workspace:Raycast(r.Position + Vector3.new(0, 40, 0), Vector3.new(0, -250, 0), par)
                if res then
                    local bp = r:FindFirstChild("PF_WW")
                    if not bp then
                        bp = mk("BodyPosition", { Name = "PF_WW", MaxForce = Vector3.new(0, 1e5, 0), P = 30000, D = 2000, Parent = r })
                    end
                    bp.Position = Vector3.new(r.Position.X, res.Position.Y + 3, r.Position.Z)
                end
            end
        else
            local r = hrp(); local bp = r and r:FindFirstChild("PF_WW"); if bp then bp:Destroy() end
        end
    end
end)

--========================= VISUALES =========================
ActivePage = pages["Visuales"]
addSection("Mundo")
addToggle("Fullbright", "fb", false, function(v)
    LIGHT.Brightness = v and 3 or 2
    if v then LIGHT.FogEnd = 1e6; LIGHT.GlobalShadows = false end
end)
addToggle("Forzar NOCHE", "night", false, function(v) if v then LIGHT.ClockTime = 0 end end)
addToggle("Forzar DÍA", "day", false, function(v) if v then LIGHT.ClockTime = 14 end end)
addSection("ESP")
local function setESP(parent, on, color, tag)
    local ex = parent:FindFirstChild(tag)
    if on then
        if not ex then local h = mk("Highlight", { Name = tag, FillColor = color, Parent = parent }) end
    elseif ex then ex:Destroy() end
end
addToggle("ESP Jugadores", "espPlayers", false, function(v)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then setESP(p.Character, v, Color3.fromRGB(0, 255, 0), "PF_EP") end
    end
end)
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c) if S.espPlayers then setESP(c, true, Color3.fromRGB(0, 255, 0), "PF_EP") end end)
end)
addToggle("ESP Dinos/NPCs", "espDinos", false, function(v)
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Model") and d:FindFirstChildOfClass("Humanoid") and d ~= LP.Character then
            setESP(d, v, Color3.fromRGB(255, 170, 0), "PF_ED")
        end
    end
end)
addToggle("ESP Montículos (solo reales)", "espDig", false, function(v)
    for _, d in ipairs(findDigSites()) do setESP(d, v, Color3.fromRGB(0, 170, 255), "PF_DIG") end
end)

--========================= SPOTS =========================
ActivePage = pages["Spots"]
addSection("Zonas")
local function scanZones()
    local z = {}
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("BasePart") then
            local n = d.Name:lower()
            if n:find("jungle") or n:find("volcano") or n:find("desert") or n:find("island")
               or n:find("grotto") or n:find("lab") or n:find("ranch") or n:find("shop") or n:find("sell") then
                if not z[d.Name] then z[d.Name] = d.Position end
            end
        end
    end
    return z
end
local function tpTo(pos) local r = hrp(); if r then r.CFrame = CFrame.new(pos + Vector3.new(0, 8, 0)) end end
addButton("Refrescar zonas", function()
    local z = scanZones(); local names = {}
    for n, _ in pairs(z) do names[#names + 1] = n end
    notify("Spots", #names .. " zonas encontradas")
end)
addDropdown("Teleport a zona", (function()
    local names = {}
    for n, _ in pairs(scanZones()) do names[#names + 1] = n end
    table.sort(names)
    if #names == 0 then names = { "(sin zonas)" } end
    return names
end)(), function(c)
    local p = scanZones()[c]; if p then tpTo(p) end
end)
addSection("Atajos")
local function tpByName(key)
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("BasePart") and d.Name:lower():find(key) then tpTo(d.Position); return end
    end
    notify("Spots", "No encontré: " .. key, RED)
end
addButton("→ Jungle", function() tpByName("jungle") end)
addButton("→ Volcano", function() tpByName("volcano") end)
addButton("→ Desert", function() tpByName("desert") end)
addButton("→ Vender (shop/sell)", function() tpByName("sell") end)
addButton("→ Dr. Ivy / Lab", function() tpByName("lab") end)
addSection("Buscar por nombre")
addInput("Buscar y TP", "ej: fossil, egg, chest", function(t)
    if t and t ~= "" then tpByName(t:lower()) end
end)

--========================= GRANJA =========================
ActivePage = pages["Granja"]
addSection("Excavación")
addToggle("Auto Cavar (perfecto)", "autodig", false)
addToggle("Teleport al montículo", "tpdig", true)
addToggle("🧲 Imán: traer montículos a ti", "magnet", false)
task.spawn(function()
    while true do task.wait(0.3)
        if S.autodig then
            local r = hrp()
            if r then
                local sites = findDigSites()
                local best, bd
                for _, p in ipairs(sites) do
                    local d = (p.Position - r.Position).Magnitude
                    if not bd or d < bd then best, bd = p, d end
                end
                if best then
                    if S.tpdig and bd and bd > 12 then r.CFrame = CFrame.new(best.Position + Vector3.new(0, 4, 0)) end
                    local pr = digPromptOf(best)
                    if pr then
                        if S.instanthold then pr.HoldDuration = 0 end
                        firePrompt(pr)
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    while true do task.wait(0.6)
        if S.magnet then
            local r = hrp()
            if r then
                local sites = findDigSites()
                local base = r.Position + r.CFrame.LookVector * 8
                for i, d in ipairs(sites) do
                    local col = (i - 1) % 6
                    local row = math.floor((i - 1) / 6)
                    pcall(function() d.CFrame = CFrame.new(base + Vector3.new(col * 5 - 12, 0, -row * 5)) end)
                end
            end
        end
    end
end)
addSection("Interacción automática")
addSlider("Radio de interacción", 5, 200, 45, "radius", nil)
addToggle("Auto Interactuar (prompts en radio)", "autoprompt", false)
task.spawn(function()
    while true do task.wait(0.35)
        if S.autoprompt then
            local r = hrp()
            if r then
                for _, p in ipairs(promptCache) do
                    if p.Enabled and p.Parent and p.Parent:IsA("BasePart") then
                        if (p.Parent.Position - r.Position).Magnitude <= S.radius then firePrompt(p) end
                    end
                end
            end
        end
    end
end)

--========================= BYPASS =========================
ActivePage = pages["Bypass"]
addSection("Pala / Prompts")
addToggle("Forzar prompts (infinito, sin línea de visión)", "forceprompt", false)
addToggle("Hold instantáneo", "instanthold", false)
task.spawn(function()
    while true do task.wait(0.9)
        if S.forceprompt or S.instanthold then
            for _, p in ipairs(promptCache) do
                if S.forceprompt then
                    p.Enabled = true
                    p.MaxActivationDistance = 1000
                    p.RequiresLineOfSight = false
                end
                if S.instanthold then p.HoldDuration = 0 end
            end
        end
    end
end)
addSection("Supervivencia")
addSlider("Gravedad", 0, 300, 196, "grav", function(v) workspace.Gravity = v end)
addToggle("Anti-Void", "antiVoid", false)
task.spawn(function()
    while true do task.wait(0.2)
        if S.antiVoid then
            local r = hrp()
            if r and r.Position.Y < -50 then r.CFrame = CFrame.new(r.Position.X, 200, r.Position.Z) end
        end
    end
end)
addToggle("Anti-AFK", "antiAfk", false)
task.spawn(function()
    while true do task.wait(60)
        if S.antiAfk then local v = game:GetService("VirtualUser"); v:CaptureController(); v:ClickButton2(Vector2.new()) end
    end
end)

--========================= DINERO / REMOTES =========================
ActivePage = pages["Dinero"]
addSection("Estado")
local coinLbl
do
    local r = mk("Frame", { Size = UDim2.new(1, -8, 0, 34), BackgroundColor3 = ROWC, BackgroundTransparency = 0.15, BorderSizePixel = 0, LayoutOrder = nextOrder() }, ActivePage)
    corner(r, 8)
    coinLbl = mk("TextLabel", { Text = "Monedas: ...", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = ACCENT, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -24, 1, 0), BackgroundTransparency = 1 }, r)
end
local function coinStat()
    local ls = LP:FindFirstChild("leaderstats")
    if ls then
        for _, v in ipairs(ls:GetChildren()) do
            if v:IsA("ValueBase") then
                local n = v.Name:lower()
                if n:find("coin") or n:find("cash") or n:find("money") or n:find("gem") then return v end
            end
        end
    end
end
task.spawn(function()
    while true do task.wait(1)
        local c = coinStat()
        if coinLbl then coinLbl.Text = "Monedas: " .. (c and tostring(c.Value) or "?") end
    end
end)
addSection("Auto-Dinero")
addButton("🔎 Detectar remote de dinero", function()
    local stat = coinStat()
    local cands = {}
    for _, d in ipairs(RS:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
            local n = d.Name:lower()
            if n:find("sell") or n:find("claim") or n:find("collect") or n:find("reward") or n:find("money") or n:find("coin") or n:find("cash") or n:find("give") then
                cands[#cands + 1] = d
            end
        end
    end
    if #cands == 0 then notify("Auto-Dinero", "Sin candidatos", RED); return end
    local found
    for _, rm in ipairs(cands) do
        local before = stat and stat.Value or 0
        pcall(function() if rm:IsA("RemoteFunction") then rm:InvokeServer() else rm:FireServer() end end)
        task.wait(0.45)
        if stat and stat.Value > before then found = rm; break end
    end
    if found then
        _G.PF_MONEY_REMOTE = found
        notify("Auto-Dinero", "✅ Detectado: " .. found.Name)
    else
        notify("Auto-Dinero", "Ninguno dio monedas. Usa el Logger o el Spammer.", ACCENT2)
    end
end)
addToggle("💰 AUTO MONEY (spam remote detectado)", "autoMoney", false)
addToggle("🪙 AUTO SELL (spam remote sell)", "autoSell", false)
task.spawn(function()
    while true do task.wait(0.2)
        if S.autoMoney and _G.PF_MONEY_REMOTE then
            local rm = _G.PF_MONEY_REMOTE
            pcall(function() if rm:IsA("RemoteFunction") then rm:InvokeServer() else rm:FireServer() end end)
        end
        if S.autoSell then
            for _, d in ipairs(RS:GetDescendants()) do
                if (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) and d.Name:lower():find("sell") then
                    pcall(function() if d:IsA("RemoteFunction") then d:InvokeServer() else d:FireServer() end end)
                end
            end
        end
    end
end)

addSection("Logger de remotes")
addToggle("Logger (imprime al vender/usar)", "remoteLog", true)
local lastRemote, lastArgs
do
    local ok = pcall(function()
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local m = getnamecallmethod()
            if (m == "FireServer" or m == "InvokeServer") and typeof(self) == "Instance" then
                lastRemote, lastArgs = self, { ... }
                if S.remoteLog then print("[REMOTE]", self:GetFullName(), m, ...) end
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
end
addButton("Repetir último remote x10", function()
    if not lastRemote then notify("Replay", "Sin remote (usa el juego)", RED); return end
    for _ = 1, 10 do pcall(function() if lastRemote:IsA("RemoteFunction") then lastRemote:InvokeServer(unpack(lastArgs or {})) else lastRemote:FireServer(unpack(lastArgs or {})) end end); task.wait(0.05) end
end)
addButton("Repetir último remote x100", function()
    if not lastRemote then notify("Replay", "Sin remote", RED); return end
    for _ = 1, 100 do pcall(function() if lastRemote:IsA("RemoteFunction") then lastRemote:InvokeServer(unpack(lastArgs or {})) else lastRemote:FireServer(unpack(lastArgs or {})) end end); task.wait(0.03) end
end)

addSection("Explorador de remotes")
local remoteNames, remoteMap = {}, {}
for _, d in ipairs(RS:GetDescendants()) do
    if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
        remoteNames[#remoteNames + 1] = d.Name
        if not remoteMap[d.Name] then remoteMap[d.Name] = d end
    end
end
table.sort(remoteNames)
if #remoteNames == 0 then remoteNames = { "(ninguno)" } end
local selRemote = remoteNames[1]
local remoteArgs = ""
addDropdown("Remote", remoteNames, function(c) selRemote = c end)
addInput("Args (coma)", "ej: 1, true, hola", function(t) remoteArgs = t end)
local function parseArgs(str)
    local out = {}
    if not str or str == "" then return out end
    for tok in str:gmatch("[^,]+") do
        tok = tok:gsub("^%s+", ""):gsub("%s+$", "")
        local n = tonumber(tok)
        if n then out[#out + 1] = n
        elseif tok == "true" then out[#out + 1] = true
        elseif tok == "false" then out[#out + 1] = false
        else out[#out + 1] = tok end
    end
    return out
end
local function fireSel(n)
    local rm = remoteMap[selRemote]
    if not rm then return end
    local a = parseArgs(remoteArgs)
    for _ = 1, (n or 1) do
        pcall(function() if rm:IsA("RemoteFunction") then rm:InvokeServer(unpack(a)) else rm:FireServer(unpack(a)) end end)
        if (n or 1) > 1 then task.wait(0.04) end
    end
end
addButton("Fire", function() fireSel(1); notify("Remote", "Fire → " .. selRemote) end)
addButton("Fire x50", function() fireSel(50); notify("Remote", "Fire x50 → " .. selRemote) end)
addToggle("Loop remote seleccionado", "loopRemote", false)
task.spawn(function()
    while true do task.wait(0.15)
        if S.loopRemote then fireSel(1) end
    end
end)

addSection("Códigos")
addInput("Código personalizado", "NESSEISHERE", function(t)
    if not t or t == "" then return end
    for _, d in ipairs(RS:GetDescendants()) do
        if (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) and (d.Name:lower():find("code") or d.Name:lower():find("redeem") or d.Name:lower():find("promo")) then
            pcall(function() if d:IsA("RemoteFunction") then d:InvokeServer(t) else d:FireServer(t) end end)
        end
    end
    notify("Código", "Enviado: " .. t)
end)
addButton("Canjear lista conocida", function()
    local CODES = { "NESSIEISHERE", "UPDATE05", "GOGRINDNESSIENEW", "SORRYFORDELAY", "UICHANGES", "OGURICAPSORRY" }
    for _, d in ipairs(RS:GetDescendants()) do
        if (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) and (d.Name:lower():find("code") or d.Name:lower():find("redeem")) then
            for _, c in ipairs(CODES) do
                pcall(function() if d:IsA("RemoteFunction") then d:InvokeServer(c) else d:FireServer(c) end end)
                task.wait(0.3)
            end
            notify("Códigos", "Enviados a " .. d.Name)
            return
        end
    end
    notify("Códigos", "Sin remote de códigos", RED)
end)

--========================= JUGADOR =========================
ActivePage = pages["Jugador"]
addSection("Personaje")
addButton("Reset", function() local c = LP.Character; if c then c:BreakJoints() end end)
addButton("Invisible (toggle)", function()
    local c = LP.Character
    if c then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                p.Transparency = p.Transparency == 1 and 0 or 1
            end
        end
    end
end)
addButton("Ver stats (consola)", function()
    local ls = LP:FindFirstChild("leaderstats")
    if ls then for _, v in ipairs(ls:GetChildren()) do print("STAT:", v.Name, "=", v.Value) end end
    notify("Stats", "En consola")
end)

--========================= EXTRAS =========================
ActivePage = pages["Extras"]
addSection("Consola Lua")
addInput("Ejecutar Lua", "print('hola')", function(t)
    local f = loadstring(t)
    if f then local ok, err = pcall(f); print(ok and "[OK]" or ("[ERR] " .. tostring(err))) end
end)
addSection("Servidor")
addButton("Rejoin", function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end)
addButton("Copiar JobId", function()
    if setclipboard then setclipboard(game.JobId); notify("JobId", game.JobId) else notify("JobId", game.JobId) end
end)
addSection("Escanear juego")
addButton("Escanear y reportar (consola)", function()
    local remotes, prompts, digs = 0, 0, #findDigSites()
    for _, d in ipairs(RS:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then remotes = remotes + 1 end
    end
    prompts = #promptCache
    print("=== REPORTE VENICE HUB ===")
    print("Remotes en ReplicatedStorage:", remotes)
    print("ProximityPrompts en el mapa:", prompts)
    print("Dig-sites detectados:", digs)
    for _, d in ipairs(RS:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then print("  remote:", d:GetFullName()) end
    end
    notify("Escaneo", remotes .. " remotes, " .. digs .. " dig-sites (consola)")
end)
addButton("Unload", function() gui:Destroy() end)

--========================= ARRANQUE =========================
do
    local first = tabList:GetChildren()[1]
    if first and first:IsA("TextButton") then
        -- seleccionar Inicio
        for _, p in pairs(pages) do p.Visible = false end
        pages["Inicio"].Visible = true
        ActivePage = pages["Inicio"]
        first.BackgroundTransparency = 0.88
        first:FindFirstChildOfClass("TextLabel").TextColor3 = TXT
        first:FindFirstChildOfClass("Frame").Visible = true
    end
end

notify("🦖 VENICE HUB v4.0", "Cargado. Abre 'Dinero' → Detectar.", ACCENT)
print("[VENICE HUB] cargado en", game.PlaceId)
