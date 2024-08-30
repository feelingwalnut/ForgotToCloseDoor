-- Check Switches.lua
local deviceIdxArray = {606, 716, 735, 739, 743}  -- Replace with actual device indices
local OnTimeInSeconds = 530  -- Set the minimum open time in seconds (e.g., 600 seconds = 10 minutes)
-- local maxOnTimeInSeconds = 700  -- Set the maximum open time in seconds 

return {
    on = {
        timer = {'every 5 minutes'},   
    },
    
    logging = {   
        level = domoticz.LOG_DEBUG,   
        marker = "Left Door Open Check" 
    },    

    execute = function(dz, item)
        local function logWrite(str, level)  -- Support function for shorthand debug log statements
            dz.log(tostring(str), level or dz.LOG_DEBUG)
        end
        
        local openDeviceCount = 0
        local openDeviceName = ""
        local openDeviceTime = 0

        for _, idx in ipairs(deviceIdxArray) do
            local device = dz.devices(idx)
            local minutesAgo = device.lastUpdate.minutesAgo * 60  -- Convert minutes to seconds

            if device.active then
                if minutesAgo > OnTimeInSeconds then
                    openDeviceCount = openDeviceCount + 1
                    openDeviceName = device.name  -- Store the name of the open device
                    openDeviceTime = minutesAgo
                end
            end
        end
local NotificationTable = {dz.NSS_HTTP, dz.NSS_EMAIL}

        if openDeviceCount == 1 then
            local message = "Device " .. openDeviceName .. " was left open for " .. tostring(openDeviceTime) .. " seconds."
            logWrite("Check switch: " .. message)
            dz.notify("Check switch", message, nil, nil, "", NotificationTable)  -- Adjust notification system as needed
        end
    end
}
