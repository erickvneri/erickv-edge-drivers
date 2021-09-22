local log = require 'log'
local caps = require 'st.capabilities'
local device_mgmt = require 'st.zigbee.device_management'

local clusters = require 'st.zigbee.zcl.clusters'
local OnOff = clusters.OnOff
local ElectricalMeasurement = clusters.ElectricalMeasurement


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
  log.info('>> [DO_CONFIGURE]')
  device:refresh()

  -- [[
  --    OnOff (Switch) Configuration
  --      - Bind Request
  --      - Report Configuration
  --      - Fetch current state
  -- ]]
  device:send(device_mgmt.build_bind_request(
    device,
    OnOff.ID,
    driver.environment_info.hub_zigbee_eui))

  device:send(
    OnOff
    .attributes
    .OnOff:configure_reporting(device,0,300))

  device:send(OnOff.attributes.OnOff:read(device))

  -- [[
  --    ElectricalMeasurement (Power Meter) Configuration
  --      - Bind Request
  --      - Report Configuration
  --      - Fetch current state
  -- ]]
  device:send(device_mgmt.build_bind_request(
    device,
    ElectricalMeasurement.ID,
    driver.environment_info.hub_zigbee_eui))

  device:send(
    ElectricalMeasurement
    .attributes
    .ActivePower:configure_reporting(device,0,300,1))

  device:send(ElectricalMeasurement.attributes.ActivePower:read(device))

  -- configure
  device:configure()
end

local function device_init(driver, device)
  log.info('>> [DEVICE_INIT]')
  device:set_component_to_endpoint_fn(component_to_endpoint)
  device:set_endpoint_to_component_fn(endpoint_to_component)

  do_configure(driver, device)
end

return { do_configure=do_configure, device_init=device_init }
