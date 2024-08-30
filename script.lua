-- Check Switches.lua
local deviceIdxArray = {606, 716, 735, 739, 743}  -- Replace with actual device indices
local OnTimeInSeconds = 530  -- Set the minimum open time in seconds (e.g., 600 seconds = 10 minutes)
local recipient = "your@email.com"  -- Replace with the actual recipient email address

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
        
        -- Notification settings
        local NotificationTable = {   
            -- table with one or more notification systems. 
            -- Can be one or more of:
            -- dz.NSS_GOOGLE_CLOUD_MESSAGING, 
            -- dz.NSS_PUSHOVER,               
            dz.NSS_HTTP, 
            -- dz.NSS_KODI, 
            -- dz.NSS_LOGITECH_MEDIASERVER, 
            -- dz.NSS_NMA,
            -- dz.NSS_PROWL, 
            -- dz.NSS_PUSHALOT, 
            -- dz.NSS_PUSHBULLET, 
            -- dz.NSS_PUSHSAFER,
        } -- uncomment the ones you need

        if openDeviceCount == 1 then
            local message = "Device " .. openDeviceName .. " was left open for " .. tostring(openDeviceTime) .. " seconds."
            logWrite("Check switch: " .. message)
            
            -- Send notifications
            dz.notify("Check switch", message, nil, nil, "", NotificationTable)
            
            -- Send email notification
            local subject = "Device Left Open Alert"
            local emailMessage = "Alert: The device '" .. openDeviceName .. "' was left open for " .. tostring(openDeviceTime) .. " seconds."
            dz.email(subject, emailMessage, recipient)
        end
    end
}
