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
local BuildBindRequest = require "st.zigbee.device_management".build_bind_request
local Battery = require "st.capabilities".battery
local Button = require "st.capabilities".button


local function send_button_event(_, device, command, zbrx)end


-- generates device battery level event
-- to default (main) profile component
--
-- @param device ZigbeeDevice
-- @param command table
local function send_battery_level_event(_, device, command)
  local level = math.floor(command.value / 2)
  return pcall(
    device.emit_event,
    device,
    Battery.battery(level))
end


-- build cluster bind request
--
-- this is supposed to happen as soon
-- as device is created or driver inits.
--
-- @param device table
-- @param hub_zigbee_eui string
-- @param cluster_id string
local function send_cluster_bind_request(device, hub_zigbee_eui, cluster_id)
  return pcall(
    device.send,
    device,
    BuildBindRequest(device, cluster_id, hub_zigbee_eui))
end


-- configure reporting of specific
-- cluster attribute.
--
-- this is supposed to happen as soon
-- as device is created or driver inits.
--
-- @param device <table>
-- @param attr <table>
local function send_attr_configure_reporting(device, attr)
  return pcall(
    device.send,
    device,
    attr:configure_reporting(device, 0, 300, 1))
end


return {
  -- SmartThings-specific events
  send_battery_level_event=send_battery_level_event,
  send_button_event=send_button_event,

  -- Zigbee-specific events
  send_cluster_bind_request=send_cluster_bind_request,
  send_attr_configure_reporting=send_attr_configure_reporting,
}
