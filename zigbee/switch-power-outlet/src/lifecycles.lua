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
local ElectricalMeasurement = clusters.ElectricalMeasurement


---------------------------------------
---- Endpoint to Component parsers ----
----- FIXME: Must improve in case driver
----- matches multi-component devices,
----- e.g. power strips.
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
  -- In order to wake device
  device:refresh()

  local function configure_reporting_by_cluster(device, driver, cluster, attribute)
    -- [[
    --  Generates cluster binding and reporting
    --  and ends by reading cluster to propagate
    --  state accordingly.
    --   - Bind Request
    --   - Report Configuration
    --   - Fetch current state
    -- ]]
    device:send(device_mgmt.build_bind_request(
      device,
      cluster.ID,
      driver.environment_info.hub_zigbee_eui))

    device:send(attribute:configure_reporting(device,0,300,1))

    device:send(attribute:read(device))
  end

  --[[
  -- Initialize configure_reporting setup
  --]]
  assert(
    device:supports_capability_by_id(caps.switch.ID),
    'Won\'t configure reporting as device doesn\'t support <Switch> capability')
  -- configure_reporting
  configure_reporting_by_cluster(
    device,
    driver,
    OnOff,
    OnOff.attributes.OnOff)

  assert(
    device:supports_capability_by_id(caps.powerMeter.ID),
    'Won\'t configure_reporting as device doesn\'t support <PowerMeter> capability')
  -- configure_reporting
  configure_reporting_by_cluster(
    device,
    driver,
    ElectricalMeasurement,
    ElectricalMeasurement.attributes.ActivePower)

  -- configure
  device:configure()
end

local function device_init(driver, device)
  device:set_component_to_endpoint_fn(component_to_endpoint)
  device:set_endpoint_to_component_fn(endpoint_to_component)

  do_configure(driver, device)
end

return { do_configure=do_configure, device_init=device_init }
