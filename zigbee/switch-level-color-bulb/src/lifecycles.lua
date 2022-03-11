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
local log = require 'log'
local caps = require 'st.capabilities'
local device_mgmt = require 'st.zigbee.device_management'

local clusters = require 'st.zigbee.zcl.clusters'
local OnOff = clusters.OnOff
local Level = clusters.Level
local Groups = clusters.Groups

local Uint16 = require "st.zigbee.data_types".Uint16


---------------------------------------
---- Endpoint to Component parsers ----
local function component_to_endpoint(_, component_id)
  return component_id == 'main' and 1 or 2
end

local function endpoint_to_component(_, ep)
  return tonumber(ep) == 1 and 'main' or 'power'
end


-------------------------
---- Driver Handlers ----
-- [[
-- Lifecyclesupported:
--   - init
--   - doConfigure
-- ]]
local function do_configure(driver, device)

  local function configure_reporting_by_cluster(device, driver, cluster, attribute)
    -- [[
    --  Generates cluster binding and reporting
    --  and ends by reading cluster to propagate
    --  state accordingly.
    --   - Bind Request
    --   - Report Configuration
    --   - Fetch current state
    -- ]]
    -- bind_request
    device:send(device_mgmt.build_bind_request(
      device,
      cluster.ID,
      driver.environment_info.hub_zigbee_eui))
      -- configure_reporting
      device:send(attribute:configure_reporting(device,0,300,1))
      -- read
      device:send(attribute:read(device))
    end

  -- Configure Switch
  -- Capability (OnOff cluster)
  assert(device:supports_capability_by_id(caps.switch.ID), '<Switch> not supported')
  configure_reporting_by_cluster(device, driver, OnOff, OnOff.attributes.OnOff)

  -- Configure SwitchLevel
  -- Capability (Level cluster)
  -- Only read attribute to avoid DDoSing
  -- the Hub and platform on custom transition
  -- times (device.preferences.transitionTime)
  assert(device:supports_capability_by_id(caps.switchLevel.ID), '<SwitchLevel> not supported')
  device:send(Level.attributes.CurrentLevel:read(device))


  --[[
    TODO: FOR V1.4.0
      - PROFILE PREFERENCE FOR GROUP ID DEF
      - HANDLE INTEGER_TO_HEX INPUT
      - SET GROUP ID AT DO_CONFIGURE
  ]]

  device:send(Groups.server.commands.ViewGroup(device))
  device:send(Groups.server.commands.AddGroup(device, 0x8004, "dimmer mode"))
  device:send(Groups.server.commands.GetGroupMembership(device, { 0x8004 }))
  -- configure
  -- In order to wake device
  device:refresh()
  device:configure()
end

local function device_init(driver, device)
  device:set_component_to_endpoint_fn(component_to_endpoint)
  device:set_endpoint_to_component_fn(endpoint_to_component)

  do_configure(driver, device)
end

local function info_changed(_, device)
  local override_group_on_update = device.preferences.overrideGroupOnUpdate
  local zigbee_group = Uint16(device.preferences.zigbeeGroup)

  if override_group_on_update then
    device:send(Groups.server.commands.RemoveAllGroups(device))
  end
  device:send(Groups.server.commands.AddGroup(device, zigbee_group, "dimmer mode"))
end


return {
  do_configure=do_configure,
  device_init=device_init,
  info_changed=info_changed
}
