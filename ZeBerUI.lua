repeat task.wait() until game:IsLoaded()

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local UI_Connections = {}
local function track(conn)
    table.insert(UI_Connections, conn)
    return conn
end

local OLD_UI_NAMES = {"frosty","frosty_Island","frosty_PrintUI","UI","UI","ExecutorUI_Main"}
local function safeDestroy(obj) if obj then pcall(function() obj:Destroy() end) end end

for _, v in ipairs(CoreGui:GetChildren()) do
    for _, name in ipairs(OLD_UI_NAMES) do
        if v.Name == name then safeDestroy(v) break end
    end
end
pcall(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        for _, v in ipairs(pg:GetChildren()) do
            for _, name in ipairs(OLD_UI_NAMES) do
                if v.Name == name then safeDestroy(v) break end
            end
        end
    end
end)
pcall(function()
    local oldBlur = Lighting:FindFirstChild("frosty_Blur")
    if oldBlur then oldBlur:Destroy() end
end)

local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Name = "frosty_Blur"
BlurEffect.Size = 0
BlurEffect.Parent = Lighting
local BLUR_OPEN, BLUR_CLOSED = 12, 0
local function setBlur(target, duration)
    TweenService:Create(BlurEffect, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = target}):Play()
end
setBlur(BLUR_OPEN, 0.4)

local NeonA = Color3.fromRGB(0x61, 0x5F, 0xF0)
local NeonB = Color3.fromRGB(0xEE, 0x49, 0xFD)
local NeonMid = Color3.fromRGB(0xB0, 0x54, 0xF7)
local Theme = {
    Background = Color3.fromRGB(22, 20, 30),
    zyColor = Color3.fromRGB(30, 28, 40),
    TextColor = Color3.fromRGB(245, 240, 255),
    NeonA = NeonA, NeonB = NeonB,
}
local function applyNeonGradient(parent, rotation, transparency)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, NeonA),
        ColorSequenceKeypoint.new(0.5, NeonMid),
        ColorSequenceKeypoint.new(1, NeonB),
    }
    g.Rotation = rotation or 45
    if transparency then g.Transparency = transparency end
    g.Parent = parent
    return g
end

local library = { currentTab = nil, flags = {}, tabs = {} }

local function drag(frame, hold)
    hold = hold or frame
    local dragging, dragStart, startPos
    track(hold.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end))
    track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "frosty"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0, 572, 0, 400)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.Active = true
Main.ZIndex = 1
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)
applyNeonGradient(Main, 45).Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.35),
    NumberSequenceKeypoint.new(0.5, 0.55),
    NumberSequenceKeypoint.new(1, 0.35),
}
local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.new(1,1,1)
MainStroke.Parent = Main
local StrokeGradient = Instance.new("UIGradient")
StrokeGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, NeonA),
    ColorSequenceKeypoint.new(0.5, NeonB),
    ColorSequenceKeypoint.new(1, NeonA),
}
StrokeGradient.Parent = MainStroke
drag(Main)
track(RunService.RenderStepped:Connect(function(dt) StrokeGradient.Rotation = (StrokeGradient.Rotation + dt * 60) % 360 end))

local Side = Instance.new("Frame")
Side.Size = UDim2.new(0, 130, 1, 0)
Side.BackgroundColor3 = Theme.zyColor
Side.BorderSizePixel = 0
Side.ClipsDescendants = true
Side.ZIndex = 2
Side.Parent = Main
Instance.new("UICorner", Side).CornerRadius = UDim.new(0, 6)
local SideGradient = Instance.new("UIGradient")
SideGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 24, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 25, 60)),
}
SideGradient.Rotation = 90
SideGradient.Parent = Side

local ScriptTitle = Instance.new("TextLabel")
ScriptTitle.Position = UDim2.new(0, 14, 0, 14)
ScriptTitle.Size = UDim2.new(1, -28, 0, 24)
ScriptTitle.BackgroundTransparency = 1
ScriptTitle.Font = Enum.Font.GothamBold
ScriptTitle.Text = "ZeBer UI"
ScriptTitle.TextColor3 = Color3.new(1,1,1)
ScriptTitle.TextSize = 14
ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left
ScriptTitle.ZIndex = 3
ScriptTitle.Parent = Side
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, NeonA),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 80, 255)),
    ColorSequenceKeypoint.new(1, NeonB),
}
TitleGradient.Parent = ScriptTitle
track(RunService.RenderStepped:Connect(function(dt) TitleGradient.Offset = Vector2.new((TitleGradient.Offset.X + dt * 0.3) % 1, 0) end))

local TabBtns = Instance.new("ScrollingFrame")
TabBtns.Position = UDim2.new(0, 10, 0, 48)
TabBtns.Size = UDim2.new(1, -20, 1, -58)
TabBtns.BackgroundTransparency = 1
TabBtns.BorderSizePixel = 0
TabBtns.ScrollBarThickness = 0
TabBtns.CanvasSize = UDim2.new(0,0,0,0)
TabBtns.ZIndex = 3
TabBtns.Parent = Side
local TabBtnsL = Instance.new("UIListLayout")
TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
TabBtnsL.Padding = UDim.new(0, 8)
TabBtnsL.Parent = TabBtns

local TabMain = Instance.new("Frame")
TabMain.Position = UDim2.new(0, 130, 0, 0)
TabMain.Size = UDim2.new(1, -130, 1, 0)
TabMain.BackgroundTransparency = 1
TabMain.BorderSizePixel = 0
TabMain.ZIndex = 2
TabMain.Parent = Main

-- ============================================================
-- 日志
-- ============================================================
local LogColors = {
    info = Color3.fromRGB(220,220,240),
    success = Color3.fromRGB(80,255,160),
    warn = Color3.fromRGB(255,200,80),
    error = Color3.fromRGB(255,80,120),
}
local LogEntries = {}
local LogMax = 100
local LogListLayout, LogScroll, LogEmptyLabel

local function refreshLogEmpty()
    if not LogScroll then return end
    local has = false
    for _, v in ipairs(LogScroll:GetChildren()) do
        if v:IsA("Frame") and v.Name:match("^LogEntry_") then has = true break end
    end
    if LogEmptyLabel then LogEmptyLabel.Visible = not has end
end

local function removeLogEntry(entry)
    for i, e in ipairs(LogEntries) do
        if e.entry == entry then table.remove(LogEntries, i) break end
    end
    pcall(function() entry:Destroy() end)
    refreshLogEmpty()
end




local lastLogMessage = nil
local lastLogEntry = nil
local lastLogCount = 0

local function addLogEntry(message, kind)
    kind = kind or "info"
    if not LogScroll or not LogListLayout then return end
    
    local msgStr = tostring(message)

    -- 【核心去重逻辑】如果新消息和上一条完全一样，且上一条还在屏幕上
    if lastLogMessage == msgStr and lastLogEntry and lastLogEntry.Parent then
        lastLogCount = lastLogCount + 1
        
        -- 找到上一条的文字标签，改成 "(x次数)"
        local label = lastLogEntry:FindFirstChild("LogText")
        if label then
            label.Text = msgStr .. (" (x%d)"):format(lastLogCount)
        end
        
        -- 同步更新表格数据（方便清空和复制）
        for i = #LogEntries, 1, -1 do
            if LogEntries[i].entry == lastLogEntry then
                LogEntries[i].message = label.Text
                break
            end
        end
        return -- 合并完成，不再生成新UI
    end

    -- 如果不一样，重置计数器，开始创建新日志
    lastLogMessage = msgStr
    lastLogCount = 1

    table.insert(LogEntries, {message = msgStr, kind = kind})
    if #LogEntries > LogMax then
        local oldest = table.remove(LogEntries, 1)
        if oldest and oldest.entry then pcall(function() oldest.entry:Destroy() end) end
    end
    local idx = #LogEntries
    local entry = Instance.new("Frame")
    entry.Name = "LogEntry_" .. idx
    entry.Size = UDim2.new(1,0,0,0)
    entry.AutomaticSize = Enum.AutomaticSize.Y
    entry.BackgroundColor3 = Color3.fromRGB(18,16,26)
    entry.BackgroundTransparency = 0.15
    entry.BorderSizePixel = 0
    entry.LayoutOrder = idx
    entry.ZIndex = 4
    entry.Parent = LogScroll
    Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 5)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = LogColors[kind] or LogColors.info
    stroke.Transparency = 0.4
    stroke.Parent = entry
    
    local label = Instance.new("TextLabel")
    label.Name = "LogText" -- 加上名字，方便去重时寻找
    label.Size = UDim2.new(1, -48, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.Position = UDim2.new(0, 10, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = msgStr
    label.TextColor3 = LogColors[kind] or LogColors.info
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.ZIndex = 5
    label.Parent = entry
    
    local delBtn = Instance.new("TextButton")
    delBtn.Size = UDim2.new(0, 22, 0, 22)
    delBtn.Position = UDim2.new(1, -28, 0, 6)
    delBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 60)
    delBtn.BackgroundTransparency = 0.3
    delBtn.BorderSizePixel = 0
    delBtn.Text = "×"
    delBtn.TextColor3 = Color3.new(1,1,1)
    delBtn.Font = Enum.Font.GothamBold
    delBtn.TextSize = 14
    delBtn.AutoButtonColor = false
    delBtn.ZIndex = 6
    delBtn.Parent = entry
    Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)
    
    delBtn.MouseButton1Click:Connect(function()
        removeLogEntry(entry)
        -- 如果删掉了正在合并的那条，清空记录状态
        if lastLogEntry == entry then
            lastLogEntry = nil
            lastLogMessage = nil
        end
    end)
    
    LogEntries[#LogEntries].entry = entry
    lastLogEntry = entry -- 记录最新的这一个，供下一次判断
    
    refreshLogEmpty()
    task.defer(function()
        if LogScroll then
            LogScroll.CanvasPosition = Vector2.new(0, math.max(0, LogListLayout.AbsoluteContentSize.Y - LogScroll.AbsoluteSize.Y))
        end
    end)
end

function printUI(message, kind, timeout)
    addLogEntry(message, kind)
    print(("[printUI][%s] %s"):format(kind or "info", tostring(message)))
end

-- ============================================================
-- ESP 逻辑
-- ============================================================

-- ============================================================
-- ESP 设置（LIGHTYX 风格功能，嵌入现有 UI）
-- ============================================================
local ESP = {
    enabled = false,
    showName = true,
    showHealth = true,
    showDistance = true,
    showBox = true,
    showOutline = false,
    showTracer = false,
    teamColor = false,
    hideAlly = false,
    maxDistance = 500,
    color = NeonB,
    data = {},
    conn = nil,
}

local BILLBOARD_NAME = "frosty_ESP_BB"
local HIGHLIGHT_NAME = "frosty_ESP_HL"
local BEAM_PREFIX = "frosty_ESP_Beam_"

local function getColorForPlayer(plr)
    if ESP.teamColor and plr.Team then
        return plr.TeamColor.Color
    end
    return ESP.color
end

local function isAlly(plr)
    if not ESP.hideAlly then return false end
    if not plr.Team or not LocalPlayer.Team then return false end
    return plr.Team == LocalPlayer.Team
end

local function destroyPlayerESP(plr)
    local d = ESP.data[plr]
    if not d then return end
    if d.bb then pcall(function() d.bb:Destroy() end) end
    if d.hl then pcall(function() d.hl:Destroy() end) end
    if d.beam then pcall(function() d.beam:Destroy() end) end
    ESP.data[plr] = nil
end

local function createPlayerESP(plr)
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not head or not root then return end

    destroyPlayerESP(plr)

    local bb = Instance.new("BillboardGui")
    bb.Name = BILLBOARD_NAME
    bb.Adornee = head
    bb.Size = UDim2.new(0, 200, 0, 40)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 0
    bb.Parent = head

    local text = Instance.new("TextLabel")
    text.Name = "Info"
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Font = Enum.Font.Code
    text.TextSize = 15
    text.TextStrokeTransparency = 0.4
    text.TextStrokeColor3 = Color3.new(0,0,0)
    text.TextColor3 = ESP.color
    text.Text = plr.Name
    text.Parent = bb

    local box = Instance.new("Frame")
    box.Name = "Box"
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 2
    box.BorderColor3 = ESP.color
    box.Size = UDim2.new(1, 0, 1, 0)
    box.Parent = bb

    local hl = Instance.new("Highlight")
    hl.Name = HIGHLIGHT_NAME
    hl.Adornee = char
    hl.FillColor = ESP.color
    hl.OutlineColor = ESP.color
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0.2
    hl.Enabled = false
    hl.Parent = char

    local beam = nil
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myRoot then
        local a0 = myRoot:FindFirstChild("frosty_ESP_Attach0")
        if not a0 then
            a0 = Instance.new("Attachment")
            a0.Name = "frosty_ESP_Attach0"
            a0.Parent = myRoot
        end
        local a1 = root:FindFirstChild("frosty_ESP_Attach1")
        if not a1 then
            a1 = Instance.new("Attachment")
            a1.Name = "frosty_ESP_Attach1"
            a1.Parent = root
        end

        beam = Instance.new("Beam")
        beam.Name = BEAM_PREFIX .. plr.Name
        beam.Attachment0 = a0
        beam.Attachment1 = a1
        beam.FaceCamera = true
        beam.Width0 = 0.08
        beam.Width1 = 0.08
        beam.Color = ColorSequence.new(ESP.color, ESP.color)
        beam.Transparency = NumberSequence.new(0.2)
        beam.Enabled = false
        beam.Parent = myRoot
    end

    ESP.data[plr] = {
        bb = bb,
        text = text,
        box = box,
        hl = hl,
        beam = beam,
        char = char,
    }
end

local function updatePlayerESP(plr)
    local d = ESP.data[plr]
    if not d then return end
    local char = plr.Character
    if not char then destroyPlayerESP(plr) return end

    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not head or not root or not hum or hum.Health <= 0 then
        if d.bb then d.bb.Enabled = false end
        if d.hl then d.hl.Enabled = false end
        if d.beam then d.beam.Enabled = false end
        return
    end

    if d.char ~= char then
        createPlayerESP(plr)
        return
    end

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local dist = myRoot and (root.Position - myRoot.Position).Magnitude or 0
    local inRange = ESP.maxDistance <= 0 or dist <= ESP.maxDistance
    local ally = isAlly(plr)

    if not inRange or ally then
        if d.bb then d.bb.Enabled = false end
        if d.hl then d.hl.Enabled = false end
        if d.beam then d.beam.Enabled = false end
        return
    end

    local col = getColorForPlayer(plr)

    if d.bb then
        d.bb.Adornee = head
        d.bb.Enabled = true

        local parts = {}
        if ESP.showName then table.insert(parts, plr.Name) end
        if ESP.showHealth then
            local maxHp = math.max(hum.MaxHealth, 1)
            table.insert(parts, ("%d HP"):format(math.floor(hum.Health / maxHp * 100)))
        end
        if ESP.showDistance then table.insert(parts, ("%d M"):format(math.floor(dist))) end

        d.text.Text = table.concat(parts, " | ")
        d.text.TextColor3 = col
        d.text.Visible = #parts > 0

        d.box.Visible = ESP.showBox
        d.box.BorderColor3 = col
        d.box.Size = UDim2.new(1, 0, 1, 0)
    end

    if d.hl then
        d.hl.Enabled = ESP.showOutline
        d.hl.FillColor = col
        d.hl.OutlineColor = col
    end

    if d.beam then
        d.beam.Enabled = ESP.showTracer
        d.beam.Color = ColorSequence.new(col, col)
    end
end

local function startESP()
    if ESP.conn then return end
    ESP.conn = RunService.RenderStepped:Connect(function()
        if not ESP.enabled then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if not ESP.data[plr] then
                    createPlayerESP(plr)
                end
                updatePlayerESP(plr)
            end
        end
    end)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then createPlayerESP(plr) end
    end
end

local function stopESP()
    if ESP.conn then pcall(function() ESP.conn:Disconnect() end) ESP.conn = nil end
    for plr in pairs(ESP.data) do destroyPlayerESP(plr) end
end

track(Players.PlayerRemoving:Connect(function(plr) destroyPlayerESP(plr) end))

-- ============================================================
-- Tab 创建
-- ============================================================
function library:Tab(name, icon)
    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Name = "Tab_" .. name
    TabScroll.Size = UDim2.new(1, -24, 1, -24)
    TabScroll.Position = UDim2.new(0, 12, 0, 12)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 3
    TabScroll.CanvasSize = UDim2.new(0,0,0,0)
    TabScroll.Visible = false
    TabScroll.ZIndex = 3
    TabScroll.Parent = TabMain
    local TabL = Instance.new("UIListLayout")
    TabL.SortOrder = Enum.SortOrder.LayoutOrder
    TabL.Padding = UDim.new(0, 12)
    TabL.Parent = TabScroll
    TabL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabScroll.CanvasSize = UDim2.new(0,0,0, TabL.AbsoluteContentSize.Y + 20)
    end)

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1,0,0,38)
    TabBtn.BackgroundColor3 = Color3.fromRGB(38,32,50)
    TabBtn.BackgroundTransparency = 0.25
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = "   " .. name
    TabBtn.TextColor3 = Theme.TextColor
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 13
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.AutoButtonColor = false
    TabBtn.ZIndex = 4
    TabBtn.Parent = TabBtns
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 5)
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Thickness = 1
    BtnStroke.Color = Color3.fromRGB(70,70,90)
    BtnStroke.Transparency = 0.5
    BtnStroke.Parent = TabBtn

    local function setTabSelected(btn, selected)
        local old = btn:FindFirstChildOfClass("UIGradient")
        if old then old:Destroy() end
        local stroke = btn:FindFirstChildOfClass("UIStroke")
        if selected then
            applyNeonGradient(btn, 45).Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0.15),
                NumberSequenceKeypoint.new(1, 0.35),
            }
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0}):Play()
            if stroke then TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.2}):Play() end
        else
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(38,32,50), BackgroundTransparency = 0.25}):Play()
            if stroke then TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.5}):Play() end
        end
    end

    local function switchTo()
        for _, t in ipairs(library.tabs) do t.scroll.Visible = false setTabSelected(t.btn, false) end
        TabScroll.Visible = true
        setTabSelected(TabBtn, true)
        library.currentTab = name
    end
    TabBtn.MouseButton1Click:Connect(switchTo)
    table.insert(library.tabs, {name = name, btn = TabBtn, scroll = TabScroll})
    if #library.tabs == 1 then switchTo() end

    local tab = {}
    function tab:Section(sectionName, opened)
        opened = opened ~= false
        local Section = Instance.new("Frame")
        Section.Name = "Section_" .. sectionName
        Section.Size = UDim2.new(1,0,0,38)
        Section.BackgroundColor3 = Theme.zyColor
        Section.BorderSizePixel = 0
        Section.ClipsDescendants = false
        Section.ZIndex = 3
        Section.Parent = TabScroll
        Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 6)

        local Header = Instance.new("TextButton")
        Header.Size = UDim2.new(1,0,0,38)
        Header.BackgroundTransparency = 1
        Header.Text = "  " .. sectionName
        Header.TextColor3 = Theme.TextColor
        Header.Font = Enum.Font.GothamBold
        Header.TextSize = 14
        Header.TextXAlignment = Enum.TextXAlignment.Left
        Header.ZIndex = 4
        Header.Parent = Section

        local glow = Instance.new("Frame")
        glow.Size = UDim2.new(1,-12,0,1)
        glow.Position = UDim2.new(0,6,1,-1)
        glow.BackgroundColor3 = Color3.new(1,1,1)
        glow.BorderSizePixel = 0
        glow.ZIndex = 4
        glow.Parent = Section
        applyNeonGradient(glow, 0).Transparency = NumberSequence.new(0.2)

        local Objs = Instance.new("Frame")
        Objs.Position = UDim2.new(0,8,0,40)
        Objs.Size = UDim2.new(1,-16,0,0)
        Objs.BackgroundTransparency = 1
        Objs.ZIndex = 3
        Objs.Parent = Section
        local ObjsL = Instance.new("UIListLayout")
        ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
        ObjsL.Padding = UDim.new(0,10)
        ObjsL.Parent = Objs

        local isOpen = opened

        local function setChildrenVisible(visible)
            Objs.Visible = visible
            for _, child in ipairs(Objs:GetChildren()) do
                if child:IsA("GuiObject")
                and not child:IsA("UIListLayout")
                and not child:IsA("UIPadding") then
                    child.Visible = visible
                end
            end
        end

        local function updateSize()
            Section.Size = UDim2.new(1, 0, 0, isOpen and (40 + ObjsL.AbsoluteContentSize.Y + 14) or 38)
            setChildrenVisible(isOpen)
        end

        updateSize()
        ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

        Header.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            updateSize()
        end)

        local section = {}
        section.refreshSize = updateSize
        section.__frame = Section
        local order = 0

        function section:Button(text, callback)
            order = order + 1
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1,0,0,40)
            Btn.BackgroundColor3 = Color3.fromRGB(36,30,48)
            Btn.BorderSizePixel = 0
            Btn.Text = "  " .. text
            Btn.TextColor3 = Theme.TextColor
            Btn.Font = Enum.Font.Gotham
            Btn.TextSize = 13
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.AutoButtonColor = false
            Btn.LayoutOrder = order
            Btn.ZIndex = 4
            Btn.Parent = Objs
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)
            local s = Instance.new("UIStroke")
            s.Thickness = 1
            s.Color = NeonB
            s.Transparency = 0.6
            s.Parent = Btn
            Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(55,40,80)}):Play() TweenService:Create(s, TweenInfo.new(0.12), {Transparency = 0.2}):Play() end)
            Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(36,30,48)}):Play() TweenService:Create(s, TweenInfo.new(0.12), {Transparency = 0.6}):Play() end)
            Btn.MouseButton1Click:Connect(function()
                local ok, err = pcall(callback)
                if not ok then printUI("按钮回调报错: " .. tostring(err), "error") end
            end)
        end

        function section:Toggle(text, flag, default, callback)
            order = order + 1
            library.flags[flag] = default or false
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1,0,0,40)
            Btn.BackgroundColor3 = Color3.fromRGB(36,30,48)
            Btn.BorderSizePixel = 0
            Btn.Text = "  " .. text
            Btn.TextColor3 = Theme.TextColor
            Btn.Font = Enum.Font.Gotham
            Btn.TextSize = 13
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.AutoButtonColor = false
            Btn.LayoutOrder = order
            Btn.ZIndex = 4
            Btn.Parent = Objs
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)
            local SwitchBg = Instance.new("Frame")
            SwitchBg.Size = UDim2.new(0,38,0,22)
            SwitchBg.Position = UDim2.new(1,-50,0.5,-11)
            SwitchBg.BackgroundColor3 = Color3.fromRGB(30,30,36)
            SwitchBg.BorderSizePixel = 0
            SwitchBg.ZIndex = 5
            SwitchBg.Parent = Btn
            Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(0,11)
            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0,18,0,18)
            Knob.Position = UDim2.new(0,2,0.5,-9)
            Knob.BackgroundColor3 = Color3.fromRGB(200,200,220)
            Knob.BorderSizePixel = 0
            Knob.ZIndex = 6
            Knob.Parent = SwitchBg
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(0,9)
            local state = library.flags[flag]
            local function setState(v, fire)
                state = v
                library.flags[flag] = v
                TweenService:Create(SwitchBg, TweenInfo.new(0.15), {BackgroundColor3 = v and NeonB or Color3.fromRGB(30,30,36)}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.15), {
                    Position = v and UDim2.new(0,18,0.5,-9) or UDim2.new(0,2,0.5,-9),
                    BackgroundColor3 = v and Color3.new(1,1,1) or Color3.fromRGB(200,200,220),
                }):Play()
                if fire and callback then
                    local ok, err = pcall(callback, v)
                    if not ok then printUI("Toggle 回调报错: " .. tostring(err), "error") end
                end
            end
            setState(state, false)
            Btn.MouseButton1Click:Connect(function() setState(not state, true) end)
        end

        function section:Slider(text, flag, default, min, max, callback)
            order = order + 1
            local min, max = min or 0, max or 100
            local value = math.clamp(default or min, min, max)
            library.flags[flag] = value
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1,0,0,40)
            Btn.BackgroundColor3 = Color3.fromRGB(36,30,48)
            Btn.BorderSizePixel = 0
            Btn.Text = "  " .. text
            Btn.TextColor3 = Theme.TextColor
            Btn.Font = Enum.Font.Gotham
            Btn.TextSize = 13
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.AutoButtonColor = false
            Btn.LayoutOrder = order
            Btn.ZIndex = 4
            Btn.Parent = Objs
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)
            local BarBg = Instance.new("Frame")
            BarBg.Size = UDim2.new(0,120,0,6)
            BarBg.Position = UDim2.new(1,-210,0.5,-3)
            BarBg.BackgroundColor3 = Color3.fromRGB(25,25,30)
            BarBg.BorderSizePixel = 0
            BarBg.ZIndex = 5
            BarBg.Parent = Btn
            Instance.new("UICorner", BarBg).CornerRadius = UDim.new(0,3)
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.new(1,1,1)
            Fill.BorderSizePixel = 0
            Fill.ZIndex = 6
            Fill.Parent = BarBg
            applyNeonGradient(Fill, 0).Transparency = NumberSequence.new(0)
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(0,3)
            local ValueBox = Instance.new("TextBox")
            ValueBox.Size = UDim2.new(0,60,0,24)
            ValueBox.Position = UDim2.new(1,-68,0.5,-12)
            ValueBox.BackgroundColor3 = Color3.fromRGB(25,25,30)
            ValueBox.BorderSizePixel = 0
            ValueBox.Text = tostring(value)
            ValueBox.TextColor3 = Theme.TextColor
            ValueBox.Font = Enum.Font.Gotham
            ValueBox.TextSize = 12
            ValueBox.ZIndex = 7
            ValueBox.ClearTextOnFocus = false
            ValueBox.Parent = Btn
            Instance.new("UICorner", ValueBox).CornerRadius = UDim.new(0,5)
            local ValueStroke = Instance.new("UIStroke")
            ValueStroke.Thickness = 1
            ValueStroke.Color = NeonB
            ValueStroke.Transparency = 0.6
            ValueStroke.Parent = ValueBox
            local dragging = false
            local function setValue(v, fire)
                v = math.clamp(v, min, max)
                library.flags[flag] = v
                Fill.Size = UDim2.new((v - min) / (max - min), 0, 1, 0)
                if not ValueBox:IsFocused() then
                    ValueBox.Text = tostring(math.floor(v * 100 + 0.5) / 100)
                end
                if fire and callback then
                    local ok, err = pcall(callback, v)
                    if not ok then printUI("Slider 回调报错: " .. tostring(err), "error") end
                end
            end
            local function updateFromMouse()
                local mx = UserInputService:GetMouseLocation().X
                local rel = (mx - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X
                setValue(min + (max - min) * math.clamp(rel, 0, 1), true)
            end
            BarBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateFromMouse()
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateFromMouse() end
            end)
            ValueBox.Focused:Connect(function()
                ValueStroke.Transparency = 0.1
                ValueBox.BackgroundColor3 = Color3.fromRGB(45,35,65)
            end)
            ValueBox.FocusLost:Connect(function()
                ValueStroke.Transparency = 0.6
                ValueBox.BackgroundColor3 = Color3.fromRGB(25,25,30)
                local num = tonumber(ValueBox.Text)
                if num then
                    num = math.clamp(num, min, max)
                    setValue(num, true)
                else
                    ValueBox.Text = tostring(library.flags[flag])
                end
            end)
            setValue(value, false)
        end

        function section:Dropdown(text, flag, options, default, callback, onOpen)
            order = order + 1
            options = options or {}
            callback = callback or function() end
            local selected = default
            library.flags[flag] = selected
            local Module = Instance.new("Frame")
            Module.Size = UDim2.new(1,0,0,40)
            Module.BackgroundColor3 = Color3.fromRGB(36,30,48)
            Module.BorderSizePixel = 0
            Module.ClipsDescendants = true
            Module.LayoutOrder = order
            Module.ZIndex = 4
            Module.Parent = Objs
            Instance.new("UICorner", Module).CornerRadius = UDim.new(0,6)
            local Header = Instance.new("TextButton")
            Header.Size = UDim2.new(1,0,0,40)
            Header.BackgroundTransparency = 1
            Header.Text = ""
            Header.AutoButtonColor = false
            Header.ZIndex = 5
            Header.Parent = Module
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(1,-80,1,0)
            TitleLabel.Position = UDim2.new(0,10,0,0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = text
            TitleLabel.TextColor3 = Theme.TextColor
            TitleLabel.Font = Enum.Font.Gotham
            TitleLabel.TextSize = 13
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.ZIndex = 6
            TitleLabel.Parent = Header
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0,100,1,0)
            ValueLabel.Position = UDim2.new(1,-130,0,0)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = selected and tostring(selected) or "请选择"
            ValueLabel.TextColor3 = NeonB
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.TextSize = 12
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.ZIndex = 6
            ValueLabel.Parent = Header
            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0,22,1,0)
            Arrow.Position = UDim2.new(1,-28,0,0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "▼"
            Arrow.TextColor3 = Color3.fromRGB(180,180,200)
            Arrow.Font = Enum.Font.GothamBold
            Arrow.TextSize = 10
            Arrow.ZIndex = 6
            Arrow.Parent = Header
            local ListFrame = Instance.new("ScrollingFrame")
            ListFrame.Size = UDim2.new(1,0,0,0)
            ListFrame.Position = UDim2.new(0,0,0,40)
            ListFrame.BackgroundColor3 = Color3.fromRGB(28,24,38)
            ListFrame.BorderSizePixel = 0
            ListFrame.ScrollBarThickness = 2
            ListFrame.CanvasSize = UDim2.new(0,0,0,0)
            ListFrame.ZIndex = 5
            ListFrame.Parent = Module
            Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0,6)
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Padding = UDim.new(0,6)
            ListLayout.Parent = ListFrame
            local ListPad = Instance.new("UIPadding")
            ListPad.PaddingTop = UDim.new(0,6)
            ListPad.PaddingBottom = UDim.new(0,6)
            ListPad.PaddingLeft = UDim.new(0,6)
            ListPad.PaddingRight = UDim.new(0,6)
            ListPad.Parent = ListFrame
            local OPTION_HEIGHT = 34
            local MAX_LIST_HEIGHT = 180
            local isOpen = false
            local function refreshListSize()
                local contentH = ListLayout.AbsoluteContentSize.Y
                ListFrame.CanvasSize = UDim2.new(0,0,0,contentH)
                local targetH = math.min(contentH, MAX_LIST_HEIGHT)
                if isOpen then
                    Module.Size = UDim2.new(1,0,0,40 + targetH + 12)
                    ListFrame.Size = UDim2.new(1,0,0,targetH + 12)
                end
            end
            local function setOpen(open)
                isOpen = open
                Arrow.Text = open and "▲" or "▼"
                if open and onOpen then
                    local ok, err = pcall(onOpen)
                    if not ok then printUI("Dropdown onOpen 报错: " .. tostring(err), "error") end
                end
                if open then
                    task.defer(function()
                        if not isOpen then return end
                        refreshListSize()
                        local targetH = math.min(ListLayout.AbsoluteContentSize.Y, MAX_LIST_HEIGHT)
                        Module.Size = UDim2.new(1,0,0,40 + targetH + 12)
                        ListFrame.Size = UDim2.new(1,0,0,targetH + 12)
                        TweenService:Create(Module, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Module.Size}):Play()
                        if section.refreshSize then section.refreshSize() end
                    end)
                else
                    TweenService:Create(Module, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,40)}):Play()
                    task.defer(function()
                        if section.refreshSize then section.refreshSize() end
                    end)
                end
            end
            Header.MouseButton1Click:Connect(function() setOpen(not isOpen) end)
            local optionButtons = {}
            local function clearOptions()
                for _, child in ipairs(ListFrame:GetChildren()) do
                    if child:IsA("TextButton") then pcall(function() child:Destroy() end) end
                end
                optionButtons = {}
            end
            local function addOption(optionText)
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1,0,0,OPTION_HEIGHT)
                OptBtn.BackgroundColor3 = Color3.fromRGB(36,30,48)
                OptBtn.BorderSizePixel = 0
                OptBtn.Text = "  " .. tostring(optionText)
                OptBtn.TextColor3 = Theme.TextColor
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 12
                OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptBtn.AutoButtonColor = false
                OptBtn.LayoutOrder = #optionButtons + 1
                OptBtn.ZIndex = 6
                OptBtn.Parent = ListFrame
                Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0,5)
                OptBtn.MouseEnter:Connect(function() TweenService:Create(OptBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60,50,85)}):Play() end)
                OptBtn.MouseLeave:Connect(function() TweenService:Create(OptBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(36,30,48)}):Play() end)
                OptBtn.MouseButton1Click:Connect(function()
                    selected = optionText
                    library.flags[flag] = selected
                    ValueLabel.Text = tostring(selected)
                    setOpen(false)
                    local ok, err = pcall(callback, selected)
                    if not ok then printUI("Dropdown 回调报错: " .. tostring(err), "error") end
                end)
                table.insert(optionButtons, OptBtn)
                task.defer(function() if isOpen then refreshListSize() end end)
            end
            for _, opt in ipairs(options) do addOption(opt) end
            return {
                Set = function(_, v)
                    selected = v
                    library.flags[flag] = v
                    ValueLabel.Text = tostring(v)
                    local ok, err = pcall(callback, v)
                    if not ok then printUI("Dropdown 回调报错: " .. tostring(err), "error") end
                end,
                Get = function() return library.flags[flag] end,
                SetOptions = function(_, newOptions)
                    clearOptions()
                    for _, opt in ipairs(newOptions or {}) do addOption(opt) end
                    local function forceResize()
                        local contentH = ListLayout.AbsoluteContentSize.Y
                        ListFrame.CanvasSize = UDim2.new(0,0,0,contentH)
                        local targetH = math.min(contentH, MAX_LIST_HEIGHT)
                        Module.Size = UDim2.new(1,0,0,40 + targetH + 12)
                        ListFrame.Size = UDim2.new(1,0,0,targetH + 12)
                        if section.refreshSize then section.refreshSize() end
                    end
                    forceResize()
                    task.defer(forceResize)
                    task.delay(0.05, forceResize)
                end,
                AddOption = function(_, opt) addOption(opt) end,
                Close = function() setOpen(false) end,
            }
        end

        function section:Label(text)
            order = order + 1
            local L = Instance.new("TextLabel")
            L.Size = UDim2.new(1,0,0,26)
            L.BackgroundTransparency = 1
            L.Text = "  " .. text
            L.TextColor3 = Color3.fromRGB(180,180,200)
            L.Font = Enum.Font.Gotham
            L.TextSize = 12
            L.TextXAlignment = Enum.TextXAlignment.Left
            L.LayoutOrder = order
            L.ZIndex = 4
            L.Parent = Objs
        end
        return section
    end
    return tab
end

-- ============================================================
-- 日志 Tab
-- ============================================================
local logTab = library:Tab("日志")
local logTabScroll
for _, t in ipairs(library.tabs) do if t.name == "日志" then logTabScroll = t.scroll break end end

-- ============================================================
-- 日志主体
-- ============================================================
local LogSection = Instance.new("Frame")
LogSection.Size = UDim2.new(1,0,1,0)
LogSection.BackgroundTransparency = 1
LogSection.ZIndex = 3
LogSection.Parent = logTabScroll

local LogToolbar = Instance.new("Frame")
LogToolbar.Size = UDim2.new(1,0,0,34)
LogToolbar.BackgroundTransparency = 1
LogToolbar.ZIndex = 4
LogToolbar.Parent = LogSection

local ClearLogBtn = Instance.new("TextButton")
ClearLogBtn.Size = UDim2.new(0,90,0,34)
ClearLogBtn.Position = UDim2.new(0,0,0,0)
ClearLogBtn.BackgroundColor3 = Color3.fromRGB(180,45,60)
ClearLogBtn.BackgroundTransparency = 0.25
ClearLogBtn.BorderSizePixel = 0
ClearLogBtn.Text = "清空日志"
ClearLogBtn.TextColor3 = Color3.new(1,1,1)
ClearLogBtn.Font = Enum.Font.GothamBold
ClearLogBtn.TextSize = 12
ClearLogBtn.AutoButtonColor = false
ClearLogBtn.ZIndex = 5
ClearLogBtn.Parent = LogToolbar
Instance.new("UICorner", ClearLogBtn).CornerRadius = UDim.new(0,6)

local CopyAllLogBtn = Instance.new("TextButton")
CopyAllLogBtn.Size = UDim2.new(0,90,0,34)
CopyAllLogBtn.Position = UDim2.new(0,98,0,0)
CopyAllLogBtn.BackgroundColor3 = Color3.fromRGB(60,120,200)
CopyAllLogBtn.BackgroundTransparency = 0.25
CopyAllLogBtn.BorderSizePixel = 0
CopyAllLogBtn.Text = "复制日志"
CopyAllLogBtn.TextColor3 = Color3.new(1,1,1)
CopyAllLogBtn.Font = Enum.Font.GothamBold
CopyAllLogBtn.TextSize = 12
CopyAllLogBtn.AutoButtonColor = false
CopyAllLogBtn.ZIndex = 5
CopyAllLogBtn.Parent = LogToolbar
Instance.new("UICorner", CopyAllLogBtn).CornerRadius = UDim.new(0,6)

-- ============================================================
-- 自动清空日志开关
-- ============================================================
local autoClearLogEnabled = false
local autoClearLogThread = nil
local AUTO_CLEAR_INTERVAL = 30

local AutoClearLogBtn = Instance.new("TextButton")
AutoClearLogBtn.Size = UDim2.new(0,110,0,34)
AutoClearLogBtn.Position = UDim2.new(0,196,0,0)
AutoClearLogBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
AutoClearLogBtn.BackgroundTransparency = 0.25
AutoClearLogBtn.BorderSizePixel = 0
AutoClearLogBtn.Text = "自动清空:关"
AutoClearLogBtn.TextColor3 = Color3.new(1,1,1)
AutoClearLogBtn.Font = Enum.Font.GothamBold
AutoClearLogBtn.TextSize = 11
AutoClearLogBtn.AutoButtonColor = false
AutoClearLogBtn.ZIndex = 5
AutoClearLogBtn.Parent = LogToolbar
Instance.new("UICorner", AutoClearLogBtn).CornerRadius = UDim.new(0,6)

AutoClearLogBtn.MouseButton1Click:Connect(function()
    autoClearLogEnabled = not autoClearLogEnabled
    if autoClearLogEnabled then
        AutoClearLogBtn.Text = "自动清空:开"
        AutoClearLogBtn.BackgroundColor3 = Color3.fromRGB(0xEE, 0x49, 0xFD)
        if autoClearLogThread then
            pcall(function() task.cancel(autoClearLogThread) end)
            autoClearLogThread = nil
        end
        autoClearLogThread = task.spawn(function()
            while autoClearLogEnabled do
                task.wait(AUTO_CLEAR_INTERVAL)
                if not autoClearLogEnabled then break end
                if LogScroll then
                    for _, child in ipairs(LogScroll:GetChildren()) do
                        if child:IsA("Frame") and child.Name:match("^LogEntry_") then
                            pcall(function() child:Destroy() end)
                        end
                    end
                end
                for i = #LogEntries, 1, -1 do
                    LogEntries[i] = nil
                end
                if refreshLogEmpty then refreshLogEmpty() end
                if updateLogCount then updateLogCount() end
                if syncLogCanvas then pcall(syncLogCanvas) end
                print("[printUI] 自动清空日志")
            end
        end)
    else
        AutoClearLogBtn.Text = "自动清空:关"
        AutoClearLogBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
        if autoClearLogThread then
            pcall(function() task.cancel(autoClearLogThread) end)
            autoClearLogThread = nil
        end
    end
end)

local LogCountLabel = Instance.new("TextLabel")
LogCountLabel.Size = UDim2.new(0,100,0,34)
LogCountLabel.Position = UDim2.new(1,-100,0,0)
LogCountLabel.BackgroundTransparency = 1
LogCountLabel.Text = "日志: 0 / 100"
LogCountLabel.TextColor3 = Color3.fromRGB(180,180,200)
LogCountLabel.Font = Enum.Font.Gotham
LogCountLabel.TextSize = 12
LogCountLabel.TextXAlignment = Enum.TextXAlignment.Right
LogCountLabel.ZIndex = 5
LogCountLabel.Parent = LogToolbar

local function updateLogCount()
    LogCountLabel.Text = ("日志: %d / %d"):format(#LogEntries, LogMax)
end

-- ============================================================
-- 调试输入区
-- ============================================================
local DEBUG_PANEL_H = 92
local DebugPanel = Instance.new("Frame")
DebugPanel.Name = "DebugPanel"
DebugPanel.Position = UDim2.new(0, 0, 0, 42)
DebugPanel.Size = UDim2.new(1, 0, 0, DEBUG_PANEL_H)
DebugPanel.BackgroundColor3 = Color3.fromRGB(20, 18, 28)
DebugPanel.BackgroundTransparency = 0.1
DebugPanel.BorderSizePixel = 0
DebugPanel.ZIndex = 4
DebugPanel.Parent = LogSection
Instance.new("UICorner", DebugPanel).CornerRadius = UDim.new(0, 6)
local DebugPanelStroke = Instance.new("UIStroke")
DebugPanelStroke.Thickness = 1
DebugPanelStroke.Color = NeonB
DebugPanelStroke.Transparency = 0.6
DebugPanelStroke.Parent = DebugPanel

local DebugInputBox = Instance.new("TextBox")
DebugInputBox.Name = "DebugInputBox"
DebugInputBox.Position = UDim2.new(0, 8, 0, 6)
DebugInputBox.Size = UDim2.new(1, -16, 1, -44)
DebugInputBox.BackgroundTransparency = 1
DebugInputBox.Text = ""
DebugInputBox.PlaceholderText = "在此输入 Lua 代码"
DebugInputBox.PlaceholderColor3 = Color3.fromRGB(120,115,140)
DebugInputBox.TextColor3 = Theme.TextColor
DebugInputBox.Font = Enum.Font.Code
DebugInputBox.TextSize = 12
DebugInputBox.TextXAlignment = Enum.TextXAlignment.Left
DebugInputBox.TextYAlignment = Enum.TextYAlignment.Top
DebugInputBox.TextWrapped = true
DebugInputBox.ClearTextOnFocus = false
DebugInputBox.ZIndex = 5
DebugInputBox.Parent = DebugPanel

local DebugBtnBar = Instance.new("Frame")
DebugBtnBar.Position = UDim2.new(0, 0, 1, -36)
DebugBtnBar.Size = UDim2.new(1, 0, 0, 36)
DebugBtnBar.BackgroundTransparency = 1
DebugBtnBar.ZIndex = 5
DebugBtnBar.Parent = DebugPanel

local DebugHint = Instance.new("TextLabel")
DebugHint.Size = UDim2.new(1, -180, 0, 30)
DebugHint.Position = UDim2.new(0, 8, 0, 3)
DebugHint.BackgroundTransparency = 1
DebugHint.Text = "Enter 执行 / Shift+Enter 换行"
DebugHint.TextColor3 = Color3.fromRGB(140, 135, 160)
DebugHint.Font = Enum.Font.Gotham
DebugHint.TextSize = 11
DebugHint.TextXAlignment = Enum.TextXAlignment.Left
DebugHint.ZIndex = 6
DebugHint.Parent = DebugBtnBar

local DebugRunBtn = Instance.new("TextButton")
DebugRunBtn.Size = UDim2.new(0, 70, 0, 30)
DebugRunBtn.Position = UDim2.new(1, -150, 0, 3)
DebugRunBtn.BackgroundColor3 = Color3.fromRGB(0xEE, 0x49, 0xFD)
DebugRunBtn.BorderSizePixel = 0
DebugRunBtn.Text = "执行"
DebugRunBtn.TextColor3 = Color3.new(1,1,1)
DebugRunBtn.Font = Enum.Font.GothamBold
DebugRunBtn.TextSize = 12
DebugRunBtn.AutoButtonColor = false
DebugRunBtn.ZIndex = 6
DebugRunBtn.Parent = DebugBtnBar
Instance.new("UICorner", DebugRunBtn).CornerRadius = UDim.new(0,6)

local DebugClearBtn = Instance.new("TextButton")
DebugClearBtn.Size = UDim2.new(0, 70, 0, 30)
DebugClearBtn.Position = UDim2.new(1, -74, 0, 3)
DebugClearBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
DebugClearBtn.BorderSizePixel = 0
DebugClearBtn.Text = "清空输入"
DebugClearBtn.TextColor3 = Color3.new(1,1,1)
DebugClearBtn.Font = Enum.Font.GothamBold
DebugClearBtn.TextSize = 11
DebugClearBtn.AutoButtonColor = false
DebugClearBtn.ZIndex = 6
DebugClearBtn.Parent = DebugBtnBar
Instance.new("UICorner", DebugClearBtn).CornerRadius = UDim.new(0,6)

local function runDebugInput()
    local code = DebugInputBox.Text
    if code == nil or code:gsub("%s","") == "" then
        printUI("调试输入为空", "warn")
        return
    end
    local execCode = code:gsub("↵", "\n")
    printUI("[调试] > " .. code:gsub("\n", " ↵ "), "info")

    local fn, compileErr = loadstring(execCode)
    if not fn then
        printUI("[调试] 编译错误: " .. tostring(compileErr), "error")
        return
    end

    local realPrint = print
    local realWarn = warn
    local function hookedPrint(...)
        local n = select("#", ...)
        local parts = {}
        for i = 1, n do parts[i] = tostring(select(i, ...)) end
        addLogEntry("[print] " .. table.concat(parts, " "), "info")
        realPrint(...)
    end
    local function hookedWarn(...)
        local n = select("#", ...)
        local parts = {}
        for i = 1, n do parts[i] = tostring(select(i, ...)) end
        addLogEntry("[warn] " .. table.concat(parts, " "), "warn")
        realWarn(...)
    end

    local env = (getfenv and getfenv(fn)) or _G
    env.print = hookedPrint
    env.warn  = hookedWarn

    local ok, result = pcall(fn)

    env.print = realPrint
    env.warn  = realWarn

    if ok then
        if result ~= nil then
            printUI("[调试] 返回: " .. tostring(result), "success")
        else
            printUI("[调试] 执行完成", "success")
        end
    else
        printUI("[调试] 运行错误: " .. tostring(result), "error")
    end
end

DebugRunBtn.MouseButton1Click:Connect(function()
    local ok, err = pcall(runDebugInput)
    if not ok then printUI("调试执行异常: " .. tostring(err), "error") end
end)
DebugClearBtn.MouseButton1Click:Connect(function()
    DebugInputBox.Text = ""
end)

DebugInputBox.Focused:Connect(function()
    DebugPanelStroke.Transparency = 0.2
end)

local lastEnterHadShift = false
track(UserInputService.InputBegan:Connect(function(input, gp)
    if not DebugInputBox:IsFocused() then return end
    if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
        lastEnterHadShift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
            or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
    end
end))

DebugInputBox.FocusLost:Connect(function(enterPressed)
    DebugPanelStroke.Transparency = 0.6
    if not enterPressed then
        lastEnterHadShift = false
        return
    end
    if lastEnterHadShift then
        DebugInputBox.Text = DebugInputBox.Text .. "↵"
        lastEnterHadShift = false
        task.defer(function()
            if DebugInputBox then DebugInputBox:CaptureFocus() end
        end)
    else
        lastEnterHadShift = false
        local ok, err = pcall(runDebugInput)
        if not ok then printUI("调试执行异常: " .. tostring(err), "error") end
    end
end)

-- ============================================================
-- 日志列表
-- ============================================================
local LOG_LIST_TOP = 42 + DEBUG_PANEL_H + 8

LogScroll = Instance.new("ScrollingFrame")
LogScroll.Position = UDim2.new(0,0,0, LOG_LIST_TOP)
LogScroll.Size = UDim2.new(1,0,1,-LOG_LIST_TOP)
LogScroll.BackgroundTransparency = 1
LogScroll.BorderSizePixel = 0
LogScroll.ScrollBarThickness = 3
LogScroll.CanvasSize = UDim2.new(0,0,0,0)
LogScroll.ZIndex = 4
LogScroll.Parent = LogSection

LogListLayout = Instance.new("UIListLayout")
LogListLayout.SortOrder = Enum.SortOrder.LayoutOrder
LogListLayout.Padding = UDim.new(0,8)
LogListLayout.Parent = LogScroll

local function syncLogCanvas()
    if not LogScroll or not LogListLayout then return end
    local contentH = LogListLayout.AbsoluteContentSize.Y
    local viewH = LogScroll.AbsoluteSize.Y
    local target = math.max(contentH, viewH)
    if math.abs(LogScroll.CanvasSize.Y.Offset - target) > 1 then
        LogScroll.CanvasSize = UDim2.new(0, 0, 0, target)
    end
    if contentH > viewH + 4 then
        if LogScroll.ScrollBarThickness ~= 3 then LogScroll.ScrollBarThickness = 3 end
    else
        if LogScroll.ScrollBarThickness ~= 0 then LogScroll.ScrollBarThickness = 0 end
    end
end

LogListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    syncLogCanvas()
    task.defer(syncLogCanvas)
end)
LogScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncLogCanvas)
task.defer(syncLogCanvas)

LogEmptyLabel = Instance.new("TextLabel")
LogEmptyLabel.Size = UDim2.new(1,0,0,40)
LogEmptyLabel.Position = UDim2.new(0,0,0, LOG_LIST_TOP + 14)
LogEmptyLabel.BackgroundTransparency = 1
LogEmptyLabel.Text = "暂无日志"
LogEmptyLabel.TextColor3 = Color3.fromRGB(120,120,140)
LogEmptyLabel.Font = Enum.Font.Gotham
LogEmptyLabel.TextSize = 13
LogEmptyLabel.ZIndex = 4
LogEmptyLabel.Parent = LogSection
LogEmptyLabel.Visible = true

-- ============================================================
-- 复制全部日志
-- ============================================================
CopyAllLogBtn.MouseButton1Click:Connect(function()
    local lines = {}
    for _, e in ipairs(LogEntries) do
        lines[#lines + 1] = string.format("[%s] %s", e.kind or "info", tostring(e.message))
    end
    if #lines == 0 then
        printUI("日志为空，没有可复制内容", "warn")
        return
    end
    local text = table.concat(lines, "\n")
    local fn = setclipboard or writeclipboard or toclipboard
    if fn then
        local ok = pcall(function() fn(text) end)
        if ok then
            printUI(("已复制 %d 条日志到剪贴板"):format(#lines), "success")
        else
            printUI("复制失败（剪贴板调用异常）", "error")
        end
    else
        printUI("当前注入器不支持剪贴板", "warn")
    end
end)

-- ============================================================
-- 清空日志
-- ============================================================
ClearLogBtn.MouseButton1Click:Connect(function()
    if LogScroll then
        for _, child in ipairs(LogScroll:GetChildren()) do
            if child:IsA("Frame") and child.Name:match("^LogEntry_") then
                pcall(function() child:Destroy() end)
            end
        end
    end
    for i = #LogEntries, 1, -1 do
        LogEntries[i] = nil
    end
    if refreshLogEmpty then refreshLogEmpty() end
    if updateLogCount then updateLogCount() end
    if syncLogCanvas then pcall(syncLogCanvas) end
    print("[printUI] 日志已清空")
end)

-- ============================================================
-- 重写 addLogEntry：每条日志右侧加"复制" + "×"
-- ============================================================
local function addLogEntryWithCopy(message, kind)
    kind = kind or "info"
    if not LogScroll or not LogListLayout then return end
    table.insert(LogEntries, {message = message, kind = kind})
    if #LogEntries > LogMax then
        local oldest = table.remove(LogEntries, 1)
        if oldest and oldest.entry then pcall(function() oldest.entry:Destroy() end) end
    end
    local idx = #LogEntries
    local entry = Instance.new("Frame")
    entry.Name = "LogEntry_" .. idx
    entry.Size = UDim2.new(1,0,0,0)
    entry.AutomaticSize = Enum.AutomaticSize.Y
    entry.BackgroundColor3 = Color3.fromRGB(18,16,26)
    entry.BackgroundTransparency = 0.15
    entry.BorderSizePixel = 0
    entry.LayoutOrder = idx
    entry.ZIndex = 4
    entry.Parent = LogScroll
    Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 5)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = LogColors[kind] or LogColors.info
    stroke.Transparency = 0.4
    stroke.Parent = entry

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -78, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.Position = UDim2.new(0, 10, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = tostring(message)
    label.TextColor3 = LogColors[kind] or LogColors.info
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.ZIndex = 5
    label.Parent = entry

    local copyBtn = Instance.new("TextButton")
    copyBtn.Name = "CopyBtn"
    copyBtn.Size = UDim2.new(0, 22, 0, 22)
    copyBtn.Position = UDim2.new(1, -56, 0, 6)
    copyBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    copyBtn.BackgroundTransparency = 0.3
    copyBtn.BorderSizePixel = 0
    copyBtn.Text = "⧉"
    copyBtn.TextColor3 = Color3.new(1,1,1)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 13
    copyBtn.AutoButtonColor = false
    copyBtn.ZIndex = 6
    copyBtn.Parent = entry
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 4)
    copyBtn.MouseButton1Click:Connect(function()
        local text = tostring(message)
        local fn = setclipboard or writeclipboard or toclipboard
        if fn then
            local ok = pcall(function() fn(text) end)
            if ok then
                printUI("已复制 1 条日志到剪贴板", "success")
            else
                printUI("复制失败", "error")
            end
        else
            printUI("当前注入器不支持剪贴板", "warn")
        end
    end)
    copyBtn.MouseEnter:Connect(function()
        TweenService:Create(copyBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0.1}):Play()
    end)
    copyBtn.MouseLeave:Connect(function()
        TweenService:Create(copyBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0.3}):Play()
    end)

    local delBtn = Instance.new("TextButton")
    delBtn.Size = UDim2.new(0, 22, 0, 22)
    delBtn.Position = UDim2.new(1, -28, 0, 6)
    delBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 60)
    delBtn.BackgroundTransparency = 0.3
    delBtn.BorderSizePixel = 0
    delBtn.Text = "×"
    delBtn.TextColor3 = Color3.new(1,1,1)
    delBtn.Font = Enum.Font.GothamBold
    delBtn.TextSize = 14
    delBtn.AutoButtonColor = false
    delBtn.ZIndex = 6
    delBtn.Parent = entry
    Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)
    delBtn.MouseButton1Click:Connect(function()
        for i, e in ipairs(LogEntries) do
            if e.entry == entry then table.remove(LogEntries, i) break end
        end
        pcall(function() entry:Destroy() end)
        if refreshLogEmpty then refreshLogEmpty() end
        if updateLogCount then updateLogCount() end
        if syncLogCanvas then pcall(syncLogCanvas) end
    end)

    LogEntries[#LogEntries].entry = entry
    if refreshLogEmpty then refreshLogEmpty() end
    if updateLogCount then updateLogCount() end
    if syncLogCanvas then pcall(syncLogCanvas) end
    task.defer(function()
        syncLogCanvas()
        if LogScroll and LogListLayout then
            local maxY = math.max(0, LogListLayout.AbsoluteContentSize.Y - LogScroll.AbsoluteSize.Y)
            if LogScroll.CanvasPosition.Y >= maxY - 40 then
                LogScroll.CanvasPosition = Vector2.new(0, maxY)
            end
        end
    end)
end

addLogEntry = addLogEntryWithCopy

-- ============================================================
-- 灵动岛
-- ============================================================
local IslandGui = Instance.new("ScreenGui")
IslandGui.Name = "frosty_Island"
IslandGui.ResetOnSpawn = false
IslandGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
IslandGui.IgnoreGuiInset = true
IslandGui.DisplayOrder = 1000
IslandGui.Parent = CoreGui
local IslandHolder = Instance.new("Frame")
IslandHolder.AnchorPoint = Vector2.new(0.5,0)
IslandHolder.Position = UDim2.new(0.5,0,0,12)
IslandHolder.Size = UDim2.new(0,180,0,36)
IslandHolder.BackgroundTransparency = 1
IslandHolder.Parent = IslandGui
local Island = Instance.new("TextButton")
Island.AnchorPoint = Vector2.new(0.5,0)
Island.Position = UDim2.new(0.5,0,0,0)
Island.Size = UDim2.new(1,0,1,0)
Island.BackgroundColor3 = Color3.fromRGB(20,18,28)
Island.BorderSizePixel = 0
Island.AutoButtonColor = false
Island.Text = ""
Island.ZIndex = 2
Island.Parent = IslandHolder
Instance.new("UICorner", Island).CornerRadius = UDim.new(1,0)
local IslandGradient = Instance.new("UIGradient")
IslandGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, NeonA),
    ColorSequenceKeypoint.new(0.5, NeonMid),
    ColorSequenceKeypoint.new(1, NeonB),
}
IslandGradient.Rotation = 45
IslandGradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.55),
    NumberSequenceKeypoint.new(0.5, 0.75),
    NumberSequenceKeypoint.new(1, 0.55),
}
IslandGradient.Parent = Island
local IslandStroke = Instance.new("UIStroke")
IslandStroke.Thickness = 1.5
IslandStroke.Color = Color3.new(1,1,1)
IslandStroke.Parent = Island
local IslandStrokeGrad = Instance.new("UIGradient")
IslandStrokeGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, NeonA),
    ColorSequenceKeypoint.new(0.5, NeonB),
    ColorSequenceKeypoint.new(1, NeonA),
}
IslandStrokeGrad.Parent = IslandStroke
local StatusDot = Instance.new("Frame")
StatusDot.AnchorPoint = Vector2.new(0,0.5)
StatusDot.Position = UDim2.new(0,14,0.5,0)
StatusDot.Size = UDim2.new(0,8,0,8)
StatusDot.BackgroundColor3 = Color3.fromRGB(80,255,160)
StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 4
StatusDot.Parent = Island
Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1,0)
local IslandLabel = Instance.new("TextLabel")
IslandLabel.AnchorPoint = Vector2.new(0,0.5)
IslandLabel.Position = UDim2.new(0,30,0.5,0)
IslandLabel.Size = UDim2.new(1,-40,1,0)
IslandLabel.BackgroundTransparency = 1
IslandLabel.Text = "UI 已开启"
IslandLabel.TextColor3 = Color3.fromRGB(240,235,255)
IslandLabel.Font = Enum.Font.GothamBold
IslandLabel.TextSize = 13
IslandLabel.TextXAlignment = Enum.TextXAlignment.Left
IslandLabel.ZIndex = 4
IslandLabel.Parent = Island
track(RunService.RenderStepped:Connect(function(dt)
    IslandStrokeGrad.Rotation = (IslandStrokeGrad.Rotation + dt * 80) % 360
end))
local uiOpen = true
local animating = false
local function setIslandState(open)
    if open then
        IslandLabel.Text = "UI 已开启"
        StatusDot.BackgroundColor3 = Color3.fromRGB(80,255,160)
    else
        IslandLabel.Text = "UI 已关闭"
        StatusDot.BackgroundColor3 = Color3.fromRGB(255,80,120)
    end
end
Island.MouseButton1Click:Connect(function()
    if animating then return end
    animating = true
    pcall(function()
        if uiOpen then
            TweenService:Create(IslandHolder, TweenInfo.new(0.12), {Size = UDim2.new(0,150,0,32)}):Play()
            task.wait(0.12)
            setBlur(BLUR_CLOSED, 0.25)
            TweenService:Create(Main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0,572,0,0)}):Play()
            task.wait(0.18)
            Main.Visible = false
            TweenService:Create(IslandHolder, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,180,0,36)}):Play()
            uiOpen = false
        else
            Main.Visible = true
            Main.Size = UDim2.new(0,572,0,0)
            setBlur(BLUR_OPEN, 0.3)
            TweenService:Create(IslandHolder, TweenInfo.new(0.12), {Size = UDim2.new(0,150,0,32)}):Play()
            task.wait(0.12)
            TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,572,0,400)}):Play()
            TweenService:Create(IslandHolder, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,180,0,36)}):Play()
            uiOpen = true
        end
        setIslandState(uiOpen)
    end)
    animating = false
end)
setIslandState(true)
updateLogCount()
printUI("[UI] 完整加载完成", "success")

-- ============================================================
-- 用法教程：如何使用 ZeBer UI 库
-- ============================================================

-- 1. 创建一个新标签页 (Tab)
local myTab = library:Tab("我的功能")

-- 2. 在标签页中创建一个折叠框/区域 (Section)
-- 参数：标题, 是否默认展开(true/false)
local mySection = myTab:Section("基础组件", true)

-- 3. 添加一个普通按钮 (Button)
-- 参数：按钮文字, 点击后触发的函数
mySection:Button("点我执行代码", function()
    printUI("按钮被点击了！", "success")
    -- 这里写你要执行的功能
end)

-- 4. 添加一个开关 (Toggle)
-- 参数：开关文字, 状态标识(flag), 默认状态(true/false), 触发函数(接收开关状态)
mySection:Toggle("开启无限跳", "inf_jump", false, function(state)
    if state then
        printUI("无限跳已开启", "info")
        -- 开启逻辑
    else
        printUI("无限跳已关闭", "warn")
        -- 关闭逻辑
    end
end)

-- 5. 添加一个滑块 (Slider)
-- 参数：文字, 状态标识, 默认值, 最小值, 最大值, 触发函数(接收当前数值)
mySection:Slider("人物移动速度", "walkspeed", 16, 16, 500, function(val)
    local char = game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = val
    end
end)

-- 6. 添加一个下拉菜单 (Dropdown)
-- 参数：文字, 状态标识, 选项列表(数组), 默认选项, 触发函数(接收选中的值)
local options = {"主城", "冰霜之地", "传奇大陆"}
mySection:Dropdown("选择传送点", "tp_point", options, "主城", function(selected)
    printUI("你选择了传送点: " .. selected, "info")
end)

-- 7. 添加纯文本提示 (Label)
-- 参数：显示的文字
mySection:Label("这是一个文本提示，可以写点说明。")

-- ============================================================
-- 进阶使用：如何获取保存的值？
-- ============================================================
-- 你所有的 Toggle 开关、Slider 数值、Dropdown 选项，
-- 都会自动保存在 library.flags 里面。
-- 比如你想在别的地方获取当前的速度：
local currentSpeed = library.flags["walkspeed"]
-- 或者判断无限跳是否开启：
if library.flags["inf_jump"] then
    -- 执行无限跳代码
end
