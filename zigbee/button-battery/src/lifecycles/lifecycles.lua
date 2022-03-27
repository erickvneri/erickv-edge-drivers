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
local battery = require "st.capabilities".battery
local button = require "st.capabilities".button
local switch_level = require "st.capabilities".switchLevel

local Uint16 = require "st.zigbee.data_types".Uint16

local PowerConfiguration = require "st.zigbee.zcl.clusters".PowerConfiguration
local Basic = require "st.zigbee.zcl.clusters".Basic
local Groups = require "st.zigbee.zcl.clusters".Groups
local OnOffButton = require "custom".OnOffButton
local ReadTuyaSpecific = require "custom".ReadTuyaSpecific
local UnkownBasic = require "custom".UnknownBasic

local send_cluster_bind_request = require "emitter".send_cluster_bind_request
local send_attr_configure_reporting = require "emitter".send_attr_configure_reporting
local send_button_capability_setup = require "emitter".send_button_capability_setup
local send_zigbee_message = require "emitter".send_zigbee_message


-- generates endpoint reference based
-- on component id string reference.
--
-- @param component_id string
local function _component_to_endpoint(_, component_id)
    if component_id == "battery" then return 0 end

    local ep = component_id:match("button(%d)")
    return ep and tonumber(ep) or 1
end


-- generates component id reference
-- based on endpoint notified by
-- _component_to_endpoint.
--
-- @param ep number (endpoint)
local function _endpoint_to_component(_, ep)
  if ep == 0 then return "battery" end

  return tonumber(ep) == 1 and "main" or "button"..ep
end


-- init lifecycle
--
-- handler component vs endpoint
-- configuration for consistency
--
-- @param device ZigbeeDevice
local function init(_, device)
  device:set_component_to_endpoint_fn(_component_to_endpoint)
  device:set_endpoint_to_component_fn(_endpoint_to_component)

  if device:supports_capability_by_id(switch_level.ID) then
    device:emit_event(switch_level.level(50))
  end
end


-- added lifecycle
--
-- handles initual
-- state configuration
--
-- @param device ZigbeeDevice
local function added(_, device)
  return send_button_capability_setup(
    device,
    device:component_count() - 1,  -- exclude "battery" component
    { "pushed", "double", "held" })
end


-- doConfigure lifecycle
--
-- handles cluster attribute
-- configuration of report and
-- request binding
--
-- @param driver ZigbeeDriver
-- @param device ZigbeeDevice
local function do_configure(driver, device)
  local err = "failed to configure device: "
  local hub_zigbee_eui = driver.environment_info.hub_zigbee_eui
  local operation_mode = device.preferences.operationMode == "SCENE" and 0x01 or 0x00
  local zigbee_group = Uint16(device.preferences.zigbeeGroup)
  local override_group_on_update = device.preferences.overrideGroupOnUpdate

  -- [[
  -- battery capability setup
  -- if device supports it
  -- ]]
  if device:supports_capability_by_id(battery.ID) then
    -- bind request
    assert(send_cluster_bind_request(
      device, hub_zigbee_eui, PowerConfiguration.ID),
      err.."BindRequest - PowerConfiguration.BatteryPercentageRemaining")

    -- configure reporting
    assert(send_attr_configure_reporting(
      device,
      PowerConfiguration.attributes.BatteryPercentageRemaining,
      -- min report time 5mins, max report time 6 hours, report on minimal change
      { min_rep=3600, max_rep=21600, min_change=1 }),
      err.."PowerConfiguration.BatteryPercentageRemaining")

    -- TODO: IS IT IMPORTANT?
    -- SUBSCRIBE TO BATTERY VOLTAGE
    -- assert(send_attr_configure_reporting(
    --   device, PowerConfiguration.attributes.BatteryVoltage),
    --   err.."PowerConfiguration.BatteryVoltage")
  end
  --[[
  -- button capability setup
  -- if device supports it
  --
  -- The following sequence of Zigbee Messages
  -- defines the steps to guarantee the compatibility
  -- at network level.
  --]]
  if device:supports_capability_by_id(button.ID) then
    -- read metadata from Basic
    assert(send_zigbee_message(device, Basic.attributes.ManufacturerName:read(device)))
    assert(send_zigbee_message(device, Basic.attributes.ZCLVersion:read(device)))
    assert(send_zigbee_message(device, Basic.attributes.ApplicationVersion:read(device)))
    assert(send_zigbee_message(device, Basic.attributes.ModelIdentifier:read(device)))
    assert(send_zigbee_message(device, Basic.attributes.PowerSource:read(device)))
    assert(send_zigbee_message(device, UnkownBasic:read(device)))

    -- read tuya-specific
    assert(send_zigbee_message(device, ReadTuyaSpecific(device)))
    assert(send_zigbee_message(device, OnOffButton:read(device)))

    -- read battery values
    assert(send_zigbee_message(device, PowerConfiguration.attributes.BatteryPercentageRemaining:read(device)))
    assert(send_zigbee_message(device, PowerConfiguration.attributes.BatteryVoltage:read(device)))

    -- device mode definition
    assert(send_zigbee_message(device, OnOffButton:write(device, operation_mode)))
    assert(send_zigbee_message(device, OnOffButton:read(device)))

    -- zigbee group configuration
    if override_group_on_update then
      assert(send_zigbee_message(device, Groups.server.commands.RemoveAllGroups(device)))
    end
    assert(send_zigbee_message(device, Groups.server.commands.AddGroup(device, zigbee_group, "dimmer mode")))
    assert(send_zigbee_message(device, Groups.server.commands.ViewGroup(device)))
    assert(send_zigbee_message(device, Groups.server.commands.GetGroupMembership(device, { zigbee_group })))

    -- TODO: CHECK PURPOSE OF DeviceTemperatureConfiguration CLUSTER
    -- TODO: CHECK PURPOSE OF Identify.IdentifyTime CLUSTER
  end
end


return {
  init=init,
  added=added,
  do_configure=do_configure
}
