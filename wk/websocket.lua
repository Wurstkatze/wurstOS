-- API to interact with the wurst websocket

function exit()
    if ws then
        ws.close()
    end
    error()
end

function connect(url)
    logger.log("Connecting to server with url "..url)
    ws, errorMessage = http.websocket(url)
    if not ws then
        logger.error("Error connecting to websocket: "..errorMessage)
        exit()
    end
    logger.log("Connected.")
end

function send(message)
    -- Auth object in payload
    local payload = { auth = { id = os.getComputerID(), label = os.getComputerLabel() } }

    -- Add messages to payload
    for index, value in pairs(message) do
        payload[index] = value
    end

    -- Send json payload
    ws.send(textutils.serialiseJSON(payload))
end

function login(timeout)
    logger.log("Log in...")

    -- timeout optional
    local timeout = timeout or 1

    -- Send log in request
    send({action = "login"})

    -- Wait for response from server
    local response = ws.receive(timeout)
    if response == nil then
        -- Abort if too many login retries
        if timeout < 3 then
            logger.warn("Login failed.")
            -- Wait one more second then previously for response
            login(timeout + 1)
        else
            logger.error("Couldn't log in: Timeout")
            exit()
        end
    end
    
    -- Json to Table
    local responseTable = textutils.unserialiseJSON(response)
    
    -- Process response
    for index, value in pairs(responseTable) do
        if index == "code" then
            if value ~= 200 then
                loginFailed = true
            end
        end
        if index == "message" then
            message = textutils.serialiseJSON(value)
        end
    end
    if loginFailed then
        logger.error("Login failed: "..message)
        exit()
    end
    logger.log("Login complete.")
end

function logout(close)
    logger.log("Log out...")
    -- Send Log out request, but don't listen -> were gone, doesn't matter what server says
    send({action = "logout" })
    logger.log("Logout complete.")

    -- Don't disconnect by default
    close = close or false
    if close then
        ws.close()
        logger.log("Disconnected from server.")
    end
end

function listen(timeout)
    -- timeout optional
    local timeout = timeout or nil

    -- Tell server that we are listening (active)
    send({action = "changeActivity", active = true})

    -- Listen for response
    logger.log("Listening...")
    local response = ws.receive(timeout)

    -- Tell server that we are no longer listening (inactive)
    send({action = "changeActivity", active = false})
    
    -- Json to Table or error when timeout / server closed
    if response == nil then
        return 0, 'timeout or server closed connection'
    end
    local responseTable = textutils.unserialiseJSON(response)

    -- Process response
    for index, value in pairs(responseTable) do
        if index == "code" then
            code = value
        end
        if index == "message" then
            message = textutils.serialiseJSON(value)
        end
    end
    return code, message
end
