local caps = require 'st.capabilities'
local clusters = require 'st.zigbee.zcl.clusters'
local OnOff = clusters.OnOff
local Level = clusters.Level

------------------- Privates -------------------
--
-- [[
-- Lower-level implementation of cluster
-- command Level.MoveToLevelWithOnOff
-- ]]
local function _send_move_to_level(device, endpoint, level, transition, ...)
  --[[
  -- MoveToLevelWithOnOff
  --   device:            ZigbeeDevice
  --   level:             Uint8         0x00
  --   transition_time:   Uint16        0x00
  --   options_mask:      LevelOptions  0x00
  --   options_override:  LevelOptions  0x00
  --]]
  return pcall(
    device.send,
    device,
    Level.server.commands.MoveToLevelWithOnOff(device, level, transition):to_endpoint(endpoint)
  )
end


------------------- Publics -------------------
-- [[
-- Implementation modules abstracted
-- in abstract class controller which
-- only encapsulates the public methods
-- ]]
local controller = {}


-- [[
-- Handles Switch command triggered from
-- the SmartThings Platform (app, scene, rule,
-- SmartApp, etc).
--
-- If user-defined preference "fadeOnSwitch"
-- is active, handler will call _send_move_to_level
-- to handle Switch through transitions.
-- ]]
function controller.onoff_handler(_, device, command)
  local ep = device:get_endpoint_for_component_id(command.component)

  if device.preferences.fadeOnSwitch then
    return controller.fade_onoff(device, ep, command.command)
  end

  assert(pcall(
    device.send, device, OnOff.server.commands.Toggle(device):to_endpoint(ep)
  ))
end


-- [[
-- Handles Siwtch command when
-- device.preferences.fadeOnSwitch
-- is set to TRUE.
-- ]]
function controller.fade_onoff(device, ep, onoff_ref)
  local attr = onoff_ref == 'off' and caps.switch.switch.off() or caps.switch.switch.on()
  local lvl = onoff_ref == 'off' and 0x00 or device.state_cache.main.switchLevel.level.value
  local transition_time = device.preferences.transitionTime * 10

  assert(_send_move_to_level(device, ep, lvl, transition_time))
  assert(pcall(
    device.emit_event_for_endpoint, device, ep, attr
  ))
end


-- [[
-- Handles Switch command triggered from
-- the SmartThings Platform (app, scene, rule,
-- SmartApp, etc)
-- ]]
function controller.level_handler(_, device, command)
  local ep = device:get_endpoint_for_component_id(command.component)
  local lvl = math.floor(((command.args.level * 0xFF) / 0x64) + 0.5)
  local transition_time = device.preferences.transitionTime * 10

  assert(_send_move_to_level(device, ep, lvl, transition_time))
  assert(pcall(
    device.emit_event_for_endpoint, device, ep, caps.switchLevel.level(command.args.level)
  ))
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
