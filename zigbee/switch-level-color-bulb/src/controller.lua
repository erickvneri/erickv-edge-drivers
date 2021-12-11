local caps = require 'st.capabilities'
local clusters = require 'st.zigbee.zcl.clusters'
local OnOff = clusters.OnOff
local Level = clusters.Level
local log = require 'log'


local controller = {}


-- [[
-- Handles Switch command triggered from
-- the SmartThings Platform (app, scene, rule,
-- SmartApp, etc)
-- ]]
function controller.onoff_handler(_, device, command)
  log.debug('>> [APP_REPORT] OnOff ZigbeeMessageTx sent')
  local ep = device:get_endpoint_for_component_id(command.component)
  local attr = OnOff.server.commands

  -- Define command
  local onoff = command.command == 'on' and attr.On or attr.Off
  return device:send(onoff(device):to_endpoint(ep))
end



-- [[
-- Handles Switch command triggered from
-- the SmartThings Platform (app, scene, rule,
-- SmartApp, etc)
-- ]]
function controller.level_handler(_, device, command)
  log.debug('>> [APP_REPORT] OnOff ZigbeeMessageTx sent')
  local ep = device:get_endpoint_for_component_id(command.component)
  for k,v in pairs(command) do print(k,v) end

  device:send(
    Level.server.commands.MoveToLevel({level=20}):to_endpoint(ep))
end


-- [[
-- Handles ZigbeeMessageRx based on
-- configured reporting for OnOff.OnOff
-- ]]
function controller.handle_onoff_remote(_, device, command, zb_rx)
  log.debug('>> [EXTERNAL_REPORT] OnOff ZigbeeMessageRx received')
  local endpoint = zb_rx.address_header.src_endpoint.value
  local onoff = command.value and caps.switch.switch.on() or caps.switch.switch.off()

  -- Platform event
  return device:emit_event_for_endpoint(endpoint, onoff)
end


return controller
