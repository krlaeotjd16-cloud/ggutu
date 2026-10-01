--[[
    끝말잇기 핵
    - 상대가 받기 어려운 단어 우선 추천/입력
    - 첫 턴 자동 감지
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ===================== 설정 =====================
local Config = {
    AutoType = true,          -- 자동으로 채팅에 입력
    Delay = 0.6,              -- 입력 전 딜레이 (초)
    PreferHard = true,        -- 어려운 단어 우선
    ShowSuggestion = true,    -- 추천 단어 출력
}

-- ===================== 단어 데이터베이스 =====================
-- 끝말잇기에서 상대가 막히기 쉬운 글자들
local HardEndings = {
    ["ㄺ"] = true, ["ㄻ"] = true, ["ㄼ"] = true, ["ㄽ"] = true,
    ["ㄾ"] = true, ["ㄿ"] = true, ["ㅀ"] = true, ["ㅄ"] = true,
    ["ㄲ"] = true, ["ㅆ"] = true, ["ㄳ"] = true, ["ㄵ"] = true,
}

-- 어려운 단어 목록 (끝글자가 까다로운 것들 위주)
local HardWords = {
    -- ㄱ으로 끝나는 거 받기 힘든 단어들
    "까르보나라", "끄트머리", "나른하다", "느타리버섯",
    "다람쥐", "도서관", "라일락", "마법사",
    "바나나", "사자", "아이스크림", "자두",
    "차표", "카페", "타조", "파스타",
    "하마", "가위", "나팔꽃", "다리미",
    
    -- 특히 받기 어려운 끝글자 단어
    "곰팡이", "넓적다리", "닭똥", "몫",
    "값", "몫돈", "흙", "긁다",
    "늙다", "맑다", "붉다", "읽다",
    "젊다", "춥다", "가략", "나략",
    
    -- 첫 턴용 강한 시작 단어
    " commodo", -- placeholder, 실제로는 아래 리스트 사용
}

-- 실제 사용 단어 풀 (끝말잇기용으로 정리)
local WordPool = {
    ["가"] = {"가위", "가방", "가수", "가족", "가재", "가마", "가루", "가시"},
    ["나"] = {"나무", "나비", "나침반", "나팔", "나그네", "나란히"},
    ["다"] = {"다리", "다람쥐", "다음", "다락방", "다스리다"},
    ["라"] = {"라이터", "라일락", "라면", "라디오", "라켓"},
    ["마"] = {"마법", "마차", "마을", "마당", "마늘", "마법사"},
    ["바"] = {"바다", "바나나", "바보", "바위", "바느질"},
    ["사"] = {"사과", "사자", "사람", "산", "사탕", "사진"},
    ["아"] = {"아이", "아침", "아파트", "안경", "아줌마"},
    ["자"] = {"자동차", "자전거", "자세", "자연", "자석"},
    ["차"] = {"차표", "차량", "차창", "차선", "차비"},
    ["카"] = {"카메라", "카페", "카드", "카펫", "카네이션"},
    ["타"] = {"타조", "타이어", "타워", "타자기", "타원"},
    ["파"] = {"파도", "파스타", "파란", "파인애플", "파출소"},
    ["하"] = {"하늘", "하마", "하루", "하품", "하와이"},
    
    -- 받기 어려운 끝글자용
    ["ㄹ"] = {"과일", "마늘", "터널", "거울", "마늘"},
    ["ㅁ"] = {"마음", "사람", "다음", "소금", "구름"},
    ["ㅂ"] = {"가방", "수업", "입", "무릎", "지붕"},
    ["ㅅ"] = {"가위", "나뭇잎", "칫솔", "버섯", "열쇠"},
}

-- 시작 단어 (첫 턴용 - 상대가 막히기 쉬운 걸로)
local StartWords = {
    "까르보나라", "끄트머리", "넓적다리", "몫",
    "흙", "값", "곰팡이", "닭똥",
    "맑다", "읽다", "젊다", "춥다",
}

-- ===================== 유틸 =====================
local function getLastChar(word)
    if not word or #word == 0 then return nil end
    return string.sub(word, -3) -- 한글은 3바이트
end

local function isHardEnding(char)
    return HardEndings[char] == true
end

local function findBestWord(lastChar, isFirstTurn)
    if isFirstTurn then
        return StartWords[math.random(1, #StartWords)]
    end

    local candidates = WordPool[lastChar]
    if not candidates or #candidates == 0 then
        -- 없으면 아무거나
        for _, list in pairs(WordPool) do
            if #list > 0 then
                return list[math.random(1, #list)]
            end
        end
        return "사과"
    end

    -- 어려운 끝글자 단어 우선
    if Config.PreferHard then
        for _, word in ipairs(candidates) do
            local endChar = getLastChar(word)
            if isHardEnding(endChar) then
                return word
            end
        end
    end

    return candidates[math.random(1, #candidates)]
end

-- ===================== 채팅 입력 =====================
local function typeWord(word)
    if not Config.AutoType then
        print("[끝말잇기] 추천:", word)
        return
    end

    task.wait(Config.Delay)

    -- 채팅창 열기 + 입력 (게임마다 키가 다를 수 있음)
    local chat = game:GetService("TextChatService")
    if chat and chat.ChatInputBarConfiguration then
        -- TextChatService 사용
        local channel = chat.TextChannels:FindFirstChild("RBXGeneral")
            or chat.TextChannels:FindFirstChild("General")
        if channel then
            channel:SendAsync(word)
            return
        end
    end

    -- 구형 채팅
    local success = pcall(function()
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local playerGui = player:WaitForChild("PlayerGui")
        -- 일반적인 채팅 입력 방식
        game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents")
            :WaitForChild("SayMessageRequest"):FireServer(word, "All")
    end)

    if not success then
        print("[끝말잇기] 자동 입력 실패 → 직접 치세요:", word)
    else
        print("[끝말잇기] 입력됨:", word)
    end
end

-- ===================== 메인 로직 =====================
local usedWords = {}
local lastEnemyWord = nil
local isMyFirstTurn = true

local function onChat(msg, speaker)
    if speaker == LocalPlayer.Name then return end

    local word = msg:match("[%w가-힣]+")
    if not word or #word < 2 then return end

    -- 이미 쓴 단어면 무시
    if usedWords[word] then return end
    usedWords[word] = true
    lastEnemyWord = word
    isMyFirstTurn = false

    local lastChar = getLastChar(word)
    if not lastChar then return end

    local best = findBestWord(lastChar, false)
    if Config.ShowSuggestion then
        print("[끝말잇기] 상대:", word, "→ 추천:", best)
    end

    typeWord(best)
end

-- 채팅 감지
local function hookChat()
    local success = pcall(function()
        local chatEvents = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents")
        chatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(data)
            if data and data.FromSpeaker and data.Message then
                onChat(data.Message, data.FromSpeaker)
            end
        end)
    end)

    if not success then
        -- TextChatService
        local tcs = game:GetService("TextChatService")
        if tcs then
            tcs.MessageReceived:Connect(function(msg)
                if msg.TextSource and msg.Text then
                    onChat(msg.Text, msg.TextSource.Name)
                end
            end)
        end
    end
end

-- 첫 턴 수동 시작용
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        -- F6 = 내가 선턴일 때 강제 시작
        local word = findBestWord(nil, true)
        print("[끝말잇기] 선턴 공격:", word)
        typeWord(word)
        isMyFirstTurn = false
    end
end)

hookChat()

print("[끝말잇기 핵] 로드됨")
print("F6 = 선턴일 때 강제 공격")
print("상대가 말하면 자동으로 어려운 단어 추천/입력")
