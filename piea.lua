--[[
Build the Pyramid! Auto Hub
by Onyx
PlaceId: 123720558354386

기능:
- 자동 블록 줍기
- 자동 피라미드 배치
- 자동 훈련 (속도/힘)
- 스피드
- 안티 AFK
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Build the Pyramid | Onyx", "DarkTheme")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local Character, Humanoid, Root

local function refresh()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    Root = Character:WaitForChild("HumanoidRootPart")
end
refresh()
LocalPlayer.CharacterAdded:Connect(refresh)

-- Config
local Config = {
    AutoPickup = false,
    AutoPlace = false,
    AutoTrainSpeed = false,
    AutoTrainStrength = false,
    SpeedHack = false,
    AntiAFK = true,

    WalkSpeed = 40,
    TweenSpeed = 80
}

-- 헬퍼: 가장 가까운 파트 찾기
local function findClosest(nameKeywords, maxDist)
    maxDist = maxDist or 500
    local closest, dist = nil, maxDist
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            local n = string.lower(v.Name)
            for _, key in pairs(nameKeywords) do
                if n:find(key) then
                    local part = v:IsA("Model") and (v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")) or v
                    if part and Root then
                        local d = (Root.Position - part.Position).Magnitude
                        if d < dist then
                            dist = d
                            closest = part
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- 부드럽게 이동
local function tweenTo(pos)
    if not Root then return end
    local tween = TweenService:Create(Root, TweenInfo.new((Root.Position - pos).Magnitude / Config.TweenSpeed, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    })
    tween:Play()
    tween.Completed:Wait()
end

-- 탭
local Main = Window:NewTab("자동")
local MainSec = Main:NewSection("핵심 자동화")

local Train = Window:NewTab("훈련")
local TrainSec = Train:NewSection("체육관")

local Move = Window:NewTab("이동")
local MoveSec = Move:NewSection("이동")

local Misc = Window:NewTab("기타")
local MiscSec = Misc:NewSection("기타")

-- ==================== 자동 블록 줍기 ====================
MainSec:NewToggle("자동 블록 줍기", "가장 가까운 블록 집기", function(v)
    Config.AutoPickup = v
    if v then
        task.spawn(function()
            while Config.AutoPickup do
                pcall(function()
                    local block = findClosest({"block", "brick", "stone", "masonry", "rock"}, 300)
                    if block then
                        tweenTo(block.Position)
                        -- 근접 프롬프트나 터치 시도
                        firetouchinterest(Root, block, 0)
                        task.wait(0.1)
                        firetouchinterest(Root, block, 1)
                        -- 클릭도 같이
                        VirtualUser:Button1Down(Vector2.new(0,0))
                        task.wait(0.05)
                        VirtualUser:Button1Up(Vector2.new(0,0))
                    end
                end)
                task.wait(0.4)
            end
        end)
    end
end)

-- ==================== 자동 피라미드 배치 ====================
MainSec:NewToggle("자동 피라미드 놓기", "블록 들고 피라미드에 배치", function(v)
    Config.AutoPlace = v
    if v then
        task.spawn(function()
            while Config.AutoPlace do
                pcall(function()
                    local pyramid = findClosest({"pyramid", "monument", "build", "place"}, 400)
                    if pyramid then
                        tweenTo(pyramid.Position)
                        firetouchinterest(Root, pyramid, 0)
                        task.wait(0.1)
                        firetouchinterest(Root, pyramid, 1)
                        VirtualUser:Button1Down(Vector2.new(0,0))
                        task.wait(0.05)
                        VirtualUser:Button1Up(Vector2.new(0,0))
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

-- ==================== 자동 훈련 ====================
TrainSec:NewToggle("자동 속도 훈련", "트레드밀 자동", function(v)
    Config.AutoTrainSpeed = v
    if v then
        task.spawn(function()
            while Config.AutoTrainSpeed do
                pcall(function()
                    local treadmill = findClosest({"treadmill", "speed", "run", "gym"}, 200)
                    if treadmill then
                        tweenTo(treadmill.Position)
                        firetouchinterest(Root, treadmill, 0)
                        task.wait(0.2)
                        firetouchinterest(Root, treadmill, 1)
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)

TrainSec:NewToggle("자동 힘 훈련", "아령/웨이트 자동", function(v)
    Config.AutoTrainStrength = v
    if v then
        task.spawn(function()
            while Config.AutoTrainStrength do
                pcall(function()
                    local weight = findClosest({"weight", "strength", "arm", "lift", "gym"}, 200)
                    if weight then
                        tweenTo(weight.Position)
                        firetouchinterest(Root, weight, 0)
                        task.wait(0.2)
                        firetouchinterest(Root, weight, 1)
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)

-- ==================== 이동 ====================
MoveSec:NewToggle("스피드 핵", "", function(v)
    Config.SpeedHack = v
    if Humanoid then
        Humanoid.WalkSpeed = v and Config.WalkSpeed or 16
    end
end)

MoveSec:NewSlider("WalkSpeed", "16 ~ 80", 16, 80, 40, function(v)
    Config.WalkSpeed = v
    if Config.SpeedHack and Humanoid then
        Humanoid.WalkSpeed = v
    end
end)

MoveSec:NewSlider("트윈 속도", "자동 이동 속도", 40, 150, 80, function(v)
    Config.TweenSpeed = v
end)

-- ==================== 기타 ====================
MiscSec:NewToggle("안티 AFK", "", function(v)
    Config.AntiAFK = v
end)

task.spawn(function()
    while true do
        if Config.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
        task.wait(40)
    end
end)

MiscSec:NewButton("캐릭터 리스폰", "", function()
    if Humanoid then Humanoid.Health = 0 end
end)

print("[Onyx] Build the Pyramid Hub 로드 완료")
