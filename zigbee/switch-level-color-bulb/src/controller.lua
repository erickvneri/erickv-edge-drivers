local caps = require 'st.capabilities'
local dtypes = require 'st.zigbee.data_types'
local clusters = require 'st.zigbee.zcl.clusters'

-- OnOff abstractions
local OnOff = clusters.OnOff
local On = OnOff.server.commands.On
local Off = OnOff.server.commands.Off

-- Level abstractions
local Level = clusters.Level
local MoveToLevel = Level.server.commands.MoveToLevel

local log = require 'log'


local controller = {}


-- [[
-- Handles Switch command triggered from
-- the SmartThings Platform (app, scene, rule,
-- SmartApp, etc)
-- ]]
function controller.onoff_handler(_, device, command)
  local ep = device:get_endpoint_for_component_id(command.component)
  local onoff = command.command == 'on' and On or Off

  return device:send(onoff(device):to_endpoint(ep))
end


-- [[
-- Handles Switch command triggered from
-- the SmartThings Platform (app, scene, rule,
-- SmartApp, etc)
-- ]]
function controller.level_handler(_, device, command)
  local ep = device:get_endpoint_for_component_id(command.component)
  local lvl = math.floor(((command.args.level * 0xFF) / 0x64) + 0.5)

  --[[
  -- MoveToLevel(
  --   device,
  --   level (default 0x00),
  --   transition_time,
  --   options_mask,
  --   options_override)
  --]]
  return device:send(MoveToLevel(device, lvl):to_endpoint(ep))
end


-- [[
-- Handles ZigbeeMessageRx based on
-- configured reporting for OnOff.OnOff
-- ]]
function controller.handle_onoff_remote(_, device, command, zb_rx)
  local endpoint = zb_rx.address_header.src_endpoint.value
  local onoff = command.value and caps.switch.switch.on() or caps.switch.switch.off()

  -- Platform event
  return device:emit_event_for_endpoint(endpoint, onoff)
end


-- [[
-- Handles ZigbeeMessageRx based on
-- configured reporting for Level.CurrentLevel
-- ]]
function controller.handle_current_level_remote(_, device, command, zb_rx)
  local ep = zb_rx.address_header.src_endpoint.value
  local lvl = math.floor(((command.value / 0xFF) * 0x64 ) + 0.5)

  return device:emit_event_for_endpoint(ep, caps.switchLevel.level(lvl))
end


return controller
