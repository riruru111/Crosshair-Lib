pcall(function()
    getgenv().Crosshair.Functions:Exit()
end)

getgenv().Crosshair = {}
local Environment = getgenv().Crosshair

local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Camera = game:GetService("Workspace").CurrentCamera

local Title = "Exunys Developer"
local FileNames = {"Crosshair", "Configuration.json", "Crosshair.json"}
local AxisX, AxisY = nil, nil
local AxisConnection, CrosshairConnection = nil, nil

Environment.Settings = {
    SendNotifications = true,
    SaveSettings = true,
    ReloadOnTeleport = true,
    Enabled = true,
    ToMouse = true
}

Environment.CrosshairSettings = {
    Size = 12,
    Thickness = 1,
    Color = "0, 255, 0",
    Transparency = 1,
    GapSize = 5,
    CenterDot = false,
    CenterDotColor = "0, 255, 0",
    CenterDotSize = 1,
    CenterDotTransparency = 1,
    CenterDotFilled = true,
}

Environment.Construction = {
    LeftLine = Drawing.new("Line"),
    RightLine = Drawing.new("Line"),
    TopLine = Drawing.new("Line"),
    BottomLine = Drawing.new("Line"),
    CenterDot = Drawing.new("Circle")
}

local function Encode(Table)
    if Table and type(Table) == "table" then
        return HttpService:JSONEncode(Table)
    end
end

local function Decode(String)
    if String and type(String) == "string" then
        return HttpService:JSONDecode(String)
    end
end

local function GetColor(Color)
    local R = tonumber(string.match(Color, "([%d]+)[%s]*,[%s]*[%d]+[%s]*,[%s]*[%d]+"))
    local G = tonumber(string.match(Color, "[%d]+[%s]*,[%s]*([%d]+)[%s]*,[%s]*[%d]+"))
    local B = tonumber(string.match(Color, "[%d]+[%s]*,[%s]*[%d]+[%s]*,[%s]*([%d]+)"))
    return Color3.fromRGB(R, G, B)
end

local function Load()
    AxisConnection, CrosshairConnection = RunService.RenderStepped:Connect(function()
        if Environment.Settings.ToMouse then
            AxisX, AxisY = UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y
        else
            AxisX, AxisY = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
        end
    end), RunService.RenderStepped:Connect(function()
        Environment.Construction.LeftLine.Visible = Environment.Settings.Enabled
        Environment.Construction.LeftLine.Color = GetColor(Environment.CrosshairSettings.Color)
        Environment.Construction.LeftLine.Thickness = Environment.CrosshairSettings.Thickness
        Environment.Construction.LeftLine.Transparency = Environment.CrosshairSettings.Transparency
        Environment.Construction.LeftLine.From = Vector2.new(AxisX + Environment.CrosshairSettings.GapSize, AxisY)
        Environment.Construction.LeftLine.To = Vector2.new(AxisX + Environment.CrosshairSettings.Size, AxisY)
        Environment.Construction.RightLine.Visible = Environment.Settings.Enabled
        Environment.Construction.RightLine.Color = GetColor(Environment.CrosshairSettings.Color)
        Environment.Construction.RightLine.Thickness = Environment.CrosshairSettings.Thickness
        Environment.Construction.RightLine.Transparency = Environment.CrosshairSettings.Transparency
        Environment.Construction.RightLine.From = Vector2.new(AxisX - Environment.CrosshairSettings.GapSize, AxisY)
        Environment.Construction.RightLine.To = Vector2.new(AxisX - Environment.CrosshairSettings.Size, AxisY)
        Environment.Construction.TopLine.Visible = Environment.Settings.Enabled
        Environment.Construction.TopLine.Color = GetColor(Environment.CrosshairSettings.Color)
        Environment.Construction.TopLine.Thickness = Environment.CrosshairSettings.Thickness
        Environment.Construction.TopLine.Transparency = Environment.CrosshairSettings.Transparency
        Environment.Construction.TopLine.From = Vector2.new(AxisX, AxisY + Environment.CrosshairSettings.GapSize)
        Environment.Construction.TopLine.To = Vector2.new(AxisX, AxisY + Environment.CrosshairSettings.Size)
        Environment.Construction.BottomLine.Visible = Environment.Settings.Enabled
        Environment.Construction.BottomLine.Color = GetColor(Environment.CrosshairSettings.Color)
        Environment.Construction.BottomLine.Thickness = Environment.CrosshairSettings.Thickness
        Environment.Construction.BottomLine.Transparency = Environment.CrosshairSettings.Transparency
        Environment.Construction.BottomLine.From = Vector2.new(AxisX, AxisY - Environment.CrosshairSettings.GapSize)
        Environment.Construction.BottomLine.To = Vector2.new(AxisX, AxisY - Environment.CrosshairSettings.Size)
        Environment.Construction.CenterDot.Visible = Environment.Settings.Enabled and Environment.CrosshairSettings.CenterDot
        Environment.Construction.CenterDot.Color = GetColor(Environment.CrosshairSettings.CenterDotColor)
        Environment.Construction.CenterDot.Radius = Environment.CrosshairSettings.CenterDotSize
        Environment.Construction.CenterDot.Transparency = Environment.CrosshairSettings.CenterDotTransparency
        Environment.Construction.CenterDot.Filled = Environment.CrosshairSettings.CenterDotFilled
        Environment.Construction.CenterDot.Position = Vector2.new(AxisX, AxisY)
    end)
end

local function SaveSettings()
    if isfile(Title.."/"..FileNames[1].."/"..FileNames[2]) then
        writefile(Title.."/"..FileNames[1].."/"..FileNames[2], Encode(Environment.Settings))
    end
    if isfile(Title.."/"..FileNames[1].."/"..FileNames[3]) then
        writefile(Title.."/"..FileNames[1].."/"..FileNames[3], Encode(Environment.CrosshairSettings))
    end
end

if Environment.Settings.SaveSettings then
    if not isfolder(Title) then
        makefolder(Title)
    end
    if not isfolder(Title.."/"..FileNames[1]) then
        makefolder(Title.."/"..FileNames[1])
    end
    if not isfile(Title.."/"..FileNames[1].."/"..FileNames[2]) then
        writefile(Title.."/"..FileNames[1].."/"..FileNames[2], Encode(Environment.Settings))
    else
        Environment.Settings = Decode(readfile(Title.."/"..FileNames[1].."/"..FileNames[2]))
    end
    if not isfile(Title.."/"..FileNames[1].."/"..FileNames[3]) then
        writefile(Title.."/"..FileNames[1].."/"..FileNames[3], Encode(Environment.CrosshairSettings))
    else
        Environment.CrosshairSettings = Decode(readfile(Title.."/"..FileNames[1].."/"..FileNames[3]))
    end
    coroutine.wrap(function()
        while wait(10) do
            SaveSettings()
        end
    end)()
else
    if isfolder(Title) then
        delfolder(Title)
    end
end

if Environment.Settings.ReloadOnTeleport then
    if syn and syn.queue_on_teleport then
        syn.queue_on_teleport(game:HttpGet("https://pastebin.com/raw/4L7an7MY"))
    end
end

Environment.Functions = {}

function Environment.Functions:Exit()
    table.foreach(Environment.Construction, function(_, Value)
        Value:Remove()
    end)
    AxisConnection:Disconnect(); CrosshairConnection:Disconnect()
    getgenv().Crosshair = nil
end

function Environment.Functions:Restart()
    table.foreach(Environment.Construction, function(_, Value)
        Value:Remove()
    end)
    AxisConnection:Disconnect(); CrosshairConnection:Disconnect()
    Load()
end

function Environment.Functions:ResetSettings()
    Environment.Settings = {
        SendNotifications = true,
        SaveSettings = true,
        ReloadOnTeleport = true,
        Enabled = true,
        ToMouse = true
    }
    Environment.CrosshairSettings = {
        Size = 12,
        Thickness = 1,
        Color = "0, 255, 0",
        Transparency = 1,
        GapSize = 5,
        CenterDot = false,
        CenterDotColor = "0, 255, 0",
        CenterDotSize = 1,
        CenterDotTransparency = 1,
        CenterDotFilled = true,
    }
    SaveSettings()
end

function Environment.Functions:SetMouseIcon(Value)
    if Value == nil then Value = true end
    UserInputService.MouseIconEnabled = Value
end

if not Drawing or not writefile or not makefolder then
    return
end

Load()
