--[[
    MormawHubTestServer.server.lua
    Instale em ServerScriptService APENAS na sua própria experiência de teste.
    Autoriza velocidade/teleporte do lado do servidor apenas no Studio ou em servidor privado,
    e apenas para o dono de uma experiência pessoal ou UserIds explicitamente autorizados.

    Para jogos pertencentes a um grupo, adicione o seu UserId em EXTRA_TESTER_USER_IDS.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Adicione aqui os UserIds numéricos dos desenvolvedores/testadores autorizados.
-- Exemplo: local EXTRA_TESTER_USER_IDS = { [123456789] = true }
local EXTRA_TESTER_USER_IDS = {}

local REMOTE_NAME = "MormawHubTestRemote"
local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if remote and not remote:IsA("RemoteEvent") then
    remote:Destroy()
    remote = nil
end
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = REMOTE_NAME
    remote.Parent = ReplicatedStorage
end

local testEnabled = {}
local savedSpeed = {}
local requestedSpeed = {}

local function isAuthorized(player)
    local isOwner = game.CreatorType == Enum.CreatorType.User and player.UserId == game.CreatorId
    return isOwner or EXTRA_TESTER_USER_IDS[player.UserId] == true
end

local function isTestEnvironment()
    return RunService:IsStudio() or game.PrivateServerId ~= ""
end

local function canTest(player)
    return isTestEnvironment() and isAuthorized(player)
end

local function sendStatus(player, message)
    remote:FireClient(player, "Status", message)
end

local function getCharacterParts(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return character, humanoid, root
end

local function findAllowedSpawn(fullName)
    if typeof(fullName) ~= "string" or #fullName > 500 then
        return nil
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        local allowed = obj:IsA("SpawnLocation")
            or (obj:IsA("BasePart") and (obj.Name == "TestSpawn" or obj.Name == "MormawTestSpawn"))
        if allowed and obj:GetFullName() == fullName then
            return obj
        end
    end
    return nil
end

local function disableTestMode(player)
    testEnabled[player] = nil
    requestedSpeed[player] = nil
    local _, humanoid = getCharacterParts(player)
    if humanoid and savedSpeed[player] ~= nil then
        humanoid.WalkSpeed = savedSpeed[player]
    end
    savedSpeed[player] = nil
    remote:FireClient(player, "TestMode", false)
    sendStatus(player, "Modo de teste desativado. A velocidade anterior foi restaurada quando possível.")
end

remote.OnServerEvent:Connect(function(player, action, value)
    if not canTest(player) then
        sendStatus(player, "Acesso negado: use o Studio/servidor privado e uma conta autorizada pelo projeto.")
        remote:FireClient(player, "TestMode", false)
        return
    end

    if action == "SetTestMode" then
        if value == true then
            local _, humanoid = getCharacterParts(player)
            if not humanoid then
                sendStatus(player, "Não foi possível ativar: o personagem ainda não tem Humanoid.")
                return
            end
            if not testEnabled[player] then
                savedSpeed[player] = humanoid.WalkSpeed
                requestedSpeed[player] = humanoid.WalkSpeed
            end
            testEnabled[player] = true
            remote:FireClient(player, "TestMode", true)
            sendStatus(player, "Modo de teste autorizado pelo servidor. Velocidade e teleporte de teste estão habilitados.")
        else
            disableTestMode(player)
        end
        return
    end

    if not testEnabled[player] then
        sendStatus(player, "Ative o modo de teste autorizado antes de executar esta ação.")
        return
    end

    if action == "SetSpeed" then
        if typeof(value) ~= "number" or value ~= value then
            sendStatus(player, "Valor de velocidade inválido.")
            return
        end
        local speed = math.clamp(math.floor(value + 0.5), 0, 100)
        local _, humanoid = getCharacterParts(player)
        if not humanoid then
            sendStatus(player, "Não foi possível alterar a velocidade: Humanoid indisponível.")
            return
        end
        requestedSpeed[player] = speed
        humanoid.WalkSpeed = speed
        sendStatus(player, "Servidor de teste aplicou WalkSpeed = " .. speed .. ".")
        return
    end

    if action == "TeleportToSpawn" then
        local spawnPart = findAllowedSpawn(value)
        if not spawnPart then
            sendStatus(player, "Destino inválido ou removido. Selecione novamente um SpawnLocation/TestSpawn.")
            return
        end
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            sendStatus(player, "Teleporte cancelado: personagem ainda não está pronto.")
            return
        end
        character:PivotTo(spawnPart.CFrame + Vector3.new(0, 4, 0))
        sendStatus(player, "Teleporte do servidor concluído para: " .. spawnPart:GetFullName())
        return
    end

    sendStatus(player, "Ação de teste desconhecida.")
end)

local function setupPlayer(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(0.25)
        if testEnabled[player] then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = requestedSpeed[player] or 16
            end
        end
    end)
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerRemoving:Connect(function(player)
    testEnabled[player] = nil
    savedSpeed[player] = nil
    requestedSpeed[player] = nil
end)
