if MCDebounce then
    warn("MCD already running!")
    return
end

pcall(function() getgenv().MCDebounce = true end)

local macroUrl = "https://trigger.macrodroid.com/<id>/MCD"
local pingInterval = 240

local httpService = game:GetService("HttpService")
local req = (syn and syn.request) or request or (http and http.request) or
    http_request

local retry = 0

local function ping()
    if retry >= 5 then
        warn("Failed to ping after 5 retries")
        retry = 0
        return false
    end

    local resp = req({
        Url = macroUrl .. "?action=ping",
        Method = "GET"
    })

    if resp.StatusCode == 200 then
        print("Ping successful")
        return true
    else
        retry = retry + 1
        warn("Ping failed, retry (" .. resp.StatusCode .. ")")
        task.wait(5)
        ping()
    end
end

local function start()
    if retry >= 5 then
        warn("Failed to send start command after 5 retries")
        retry = 0
        return false
    end

    local resp = req({
        Url = macroUrl .. "?action=start",
        Method = "GET"
    })

    if resp.StatusCode == 200 then
        print("Detect started")
        return true
    else
        retry = retry + 1
        warn("Failed to start, retry (" .. resp.StatusCode .. ")")
        task.wait(5)
        start()
    end
end


local function stop()
    if retry >= 5 then
        warn("Failed to send stop command after 5 retries")
        retry = 0
        return false
    end

    local resp = req({
        Url = macroUrl .. "?action=stop",
        Method = "GET"
    })

    if resp.StatusCode == 200 then
        print("Detect stopped")
        return true
    else
        retry = retry + 1
        warn("Failed to stop, retry (" .. resp.StatusCode .. ")")
        task.wait(5)
        stop()
    end
end

-- Start the detect
start()

-- Ping every 4 minutes
while task.wait(240) do
    ping()
end

-- Stop when player leaves
game.Players.PlayerRemoving:Connect(function()
    stop()
end)
