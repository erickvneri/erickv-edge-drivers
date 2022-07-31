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
local log = require "log"
local battery = require "st.capabilities".battery
local button = require "st.capabilities".button
local cooling_setpoint = require "st.capabilities".thermostatCoolingSetpoint
local heating_setpoint = require "st.capabilities".thermostatHeatingSetpoint
local switch_level = require "st.capabilities".switchLevel
local window_shade = require "st.capabilities".windowShade
local lock = require "st.capabilities".lock

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

-- Profile options for
-- infoChanged lifecycle
-- handler.
local PROFILE_OPTS = {
  DEFAULT = "button-battery",
  COOLING_SETPOINT = "button-battery-coolingSetpoint",
  HEATING_SETPOINT = "button-battery-heatingSetpoint",
  LEVEL = "button-battery-level",
  LOCK_UNLOCK = "button-battery-lock",
  WINDOW_SHADE = "button-battery-windowShade"
}


-- _set_rotation_capability_defaults populates
-- the capability that aims to the rotation
-- option defined via device preferences
--
-- @param option string
-- @param device ZigbeeDevice
local function _set_rotation_capability_defaults(option, prefs, device)
  -- Populate capability based on
    -- Rotation Option configuration
    if option == "LEVEL" then
      device:emit_event(switch_level.level(prefs.level))
    elseif option == "COOLING_SETPOINT" then
      device:emit_event(cooling_setpoint.coolingSetpoint({
        value = prefs.coolingSetpointTemp,
        unit = prefs.coolingSetpointUnit
      }))
    elseif option == "HEATING_SETPOINT" then
      device:emit_event(heating_setpoint.heatingSetpoint({
        value = prefs.heatingSetpointTemp,
        unit = prefs.heatingSetpointUnit
      }))
    elseif option == "LOCK_UNLOCK" then
      local lock_state = string.lower(prefs.lockState)
      device:emit_event(lock.lock(lock_state))
    elseif option == "WINDOW_SHADE" then
      device:emit_event(
        window_shade.supportedWindowShadeCommands({ "open", "close", "pause" }))
      local lock_state = string.lower(prefs.windowShadeState)
      device:emit_event(window_shade.windowShade(lock_state))
    end
end


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


-- info_changed lifecycle
--
-- Among other user-defined
-- settings that can trigger
-- this lifecycle, it is expected
-- to address the type of ROTATION
-- MODE defined at the profile
-- preferences which switches
-- between the declared profiles
-- aiming to the behaviour of
-- the Smart Knob rotation.
--
-- @param device ZigbeeDevice
local function info_changed(_, device)
  local prefs = device.preferences


  local update_meta_success = pcall(
    device.try_update_metadata,
    device,
    { profile = PROFILE_OPTS[prefs.rotationOption] })

  if update_meta_success then
    log.info("Profile option is now "..prefs.rotationOption)
    assert(pcall(
      _set_rotation_capability_defaults,
      prefs.rotationOption,
      prefs,
      device), "error while populating capability for rotationOption")
  else
    log.error("Couldn't switch to profile option "..prefs.rotationOption)
  end
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
  end
end


return {
  init=init,
  added=added,
  info_changed=info_changed,
  do_configure=do_configure
}
