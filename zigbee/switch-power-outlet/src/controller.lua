-- Copyright 2022 Erick Israel Vazquez Neri
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
local caps = require 'st.capabilities'
local clusters = require 'st.zigbee.zcl.clusters'
local OnOff = clusters.OnOff


local controller = {}

-- [[
-- Handles Switch command triggered from
-- the SmartThings Platform (app, scene, rule,
-- SmartApp, etc)
-- ]]
function controller.onoff_handler(_, device, command)
  local ep = device:get_endpoint_for_component_id(command.component)
  local attr = OnOff.server.commands

  -- Define command
  local onoff = command.command == 'on' and attr.On or attr.Off
  return device:send(onoff(device):to_endpoint(ep))
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
-- configured reporting for ElectricalMeasurement.ActivePower
-- ]]
function controller.handle_power_remote(_, device, command, zb_rx)
  local endpoint = zb_rx.address_header.src_endpoint.value

  return device:emit_event_for_endpoint(
    endpoint, caps.powerMeter.power(command.value / 10))
end


return controller
