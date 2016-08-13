--[[

# Summary : Progessively shut lights in a room when no presence is detected.
# Description :

During day, it closes lights after 1 minute of inactivty.

At night, it dims the lights after 1 minutes of inactivty and shut
them after 5 minutes so you know when the lights are about to shut
without going all dark.

This script should be run every few seconds.

Note : my scene 15 is 50% dim and my scene 16 is completely shut.

]]--

-- This should be done in a startup script and made available for all scripts
local devicesByIds = {}
for i,d in pairs(luup.devices) do
  devicesByIds[d.description] = i
end

local dimSceneId, shutSceneId = 15, 16
local runSceneId = nil
local now = os.time()

-- Get the last trip time of the room sensor
local sensorId = devicesByIds["SalonDetector"]
local sensorURN = "urn:micasaverde-com:serviceId:SecuritySensor1"
local lastTrip, lastMod = luup.variable_get(sensorURN, "LastTrip", sensorId)
-- Return if last trip is not available
if lastTrip == nil then
  luup.log("Could not find LastTrip of Security Sensor #" .. sensorId)
  return
else
  lastTrip = tonumber(lastTrip)
end

if lastTrip < (now - (5 * 60)) then
  runSceneId = shutSceneId
elseif lastTrip < (now - (60)) then
  -- At night be more concilient, we dim the lights first
  if luup.is_night() then
    runSceneId = dimSceneId
  else
    runSceneId = shutSceneId
  end
end

if runSceneId then
  luup.call_action("urn:micasaverde-com:serviceId:HomeAutomationGateway1", "RunScene", { SceneNum = runSceneId }, 0)
end
