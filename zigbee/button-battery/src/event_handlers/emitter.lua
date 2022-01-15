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
local build_bind_request = require "st.zigbee.device_management".build_bind_request
local battery = require "st.capabilities".battery
local button = require "st.capabilities".button

-- button event map
local button_event_map = {
  [0x00] = "pushed",
  [0x01] = "double",
  [0x02] = "held"
}


-- send device capability event
-- and propagates SmartThings API
-- accordingly.
--
-- @param ep     number
-- @param device ZigbeeDevice
-- @param event  st.capability.attribute_event
local function _send_device_event(ep, device, event)
  return pcall(
    device.emit_event_for_endpoint,
    device,
    ep,
    event)
end


-- handles incoming ZigbeeMessageRx
-- for button-specific events and
-- sends device event accordingly
--
-- @param device ZigbeeDevice
-- @param zbrx   ZigbeeMessageRx
local function send_button_event(_, device, zbrx)
  local ep = zbrx.address_header.src_endpoint.value
  local event = tostring(zbrx.body.zcl_body):match("GenericBody:  0(%d)")

  return assert(_send_device_event(
    ep,
    device,
    button.button({value = button_event_map[tonumber(event)]})))
end


-- generates device battery level event
-- to default (main) profile component
--
-- @param device  ZigbeeDevice
-- @param command ZigbeeMessageRx
local function send_battery_level_event(_, device, command)
  local level = math.floor(command.value / 2)

  return assert(_send_device_event(
    1,
    device,
    battery.battery(level)))
end


-- build cluster bind request
--
-- this is supposed to happen as soon
-- as device is created or driver inits.
--
-- @param device         ZigbeeDevice
-- @param hub_zigbee_eui string
-- @param cluster_id     Uint8
local function send_cluster_bind_request(device, hub_zigbee_eui, cluster_id)
  return pcall(
    device.send,
    device,
    build_bind_request(device, cluster_id, hub_zigbee_eui))
end


-- configure reporting of specific
-- cluster attribute.
--
-- this is supposed to happen as soon
-- as device is created or driver inits.
--
-- @param device table
-- @param attr   table
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
