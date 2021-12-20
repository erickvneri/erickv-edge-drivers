local log = require 'log'
local caps = require 'st.capabilities'
local device_mgmt = require 'st.zigbee.device_management'

local clusters = require 'st.zigbee.zcl.clusters'
local OnOff = clusters.OnOff
local Level = clusters.Level


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

  -- configure
  device:configure()
end

local function device_init(driver, device)
  device:set_component_to_endpoint_fn(component_to_endpoint)
  device:set_endpoint_to_component_fn(endpoint_to_component)

  do_configure(driver, device)
end

return { do_configure=do_configure, device_init=device_init }
