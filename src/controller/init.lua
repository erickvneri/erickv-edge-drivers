local clusters = require 'st.zigbee.zcl.clusters'
local OnOff = clusters.OnOff
local ElectricalMeasurement = clusters.ElectricalMeasurement

local caps = require 'st.capabilities'
local log = require 'log'
--
-- SubDriver attribute configurations
local attr_config = require 'controller.attr_config'

-- Pretty printer
local pprint = function(msg)
  local pp = require 'st.utils'.stringify_table
  log.debug(pp(msg))
end


---------------------------
---- SUPPORTED DEVICES ----
local SUPPORTED_FINGERPRINTS = {
  { mn='Samjin', model='outlet' }
}


------------------------------
---- OAuth-like interface ----
local function is_supported (opts, driver, device)
  local mn = device:get_manufacturer()
  local model = device:get_model()
  log.info('>> [VALIDATE FINGERPRINT] manufacturer: '..mn..', model: '..model)

  for _, fingerprint in ipairs(SUPPORTED_FINGERPRINTS) do
    if mn == fingerprint.mn then
      if model == fingerprint.model then
        log.info('>> [SUCCESS] FINGERPRINT SUPPORTED')
        return true
      end
    end
  end
  log.error('>> [ERROR] FINGERPRINT NOT SUPPORTED')
  return false
end


--------------------------------------
---- Device Capability Controllers ----
local function onoff_handler(driver, device, command)
  log.debug('>> [APP_REPORT] OnOff ZigbeeMessageTx sent')

  local endpoint = device:get_endpoint_for_component_id(command.component)

  if command.command == 'on' then
    -- Platform command
    device:emit_event_for_endpoint(endpoint, caps.switch.switch.on())
    -- Zigbee command
    device:send(OnOff.server.commands.On(device):to_endpoint(endpoint))
  else
    -- Platform command
    device:emit_event_for_endpoint(endpoint, caps.switch.switch.off())
    -- Zigbee command
    device:send(OnOff.server.commands.Off(device):to_endpoint(endpoint))
  end
end

local function handle_onoff_remote(_, device, command, zb_rx)
  log.debug('>> [EXTERNAL_REPORT] OnOff ZigbeeMessageRx received')
  local endpoint = zb_rx.address_header.src_endpoint.value
  local onoff = command.value and caps.switch.switch.on() or caps.switch.switch.off()

  -- Platform event
  device:emit_event_for_endpoint(endpoint, onoff)
end

local function handle_power_remote(_, device, command, zb_rx)
  log.info('>> [EXTERNAL_REPORT] ElectricalMeasurement ZigbeeMessageRx received')
  --local endpoint = zb_rx.address_header.src_endpoint.value
  local endpoint = device:get_endpoint_for_component_id('power')

  -- Platform event
  device:emit_event_for_endpoint(endpoint, caps.powerMeter.power(command.value / 10))
end

------------------------------
---- Controller SubDriver ----
local controller_subdriver = {
  NAME = 'controller',
  cluster_configuration = {
    [caps.switch.ID] = attr_config.onoff_cluster_config,
    [caps.powerMeter.ID] = attr_config.power_cluster_config
  },
  can_handle = is_supported,
  zigbee_handlers = {
    attr = {
      -- Switch
      [OnOff.ID] = {
        [OnOff.attributes.OnOff.ID] = handle_onoff_remote
      },
      -- Power Meter
      [ElectricalMeasurement.ID] = {
        [ElectricalMeasurement.attributes.ActivePower.ID] = handle_power_remote
      }
    }
  },
  capability_handlers = {
    [caps.switch.ID] = {
      [caps.switch.commands.on.NAME] = onoff_handler,
      [caps.switch.commands.off.NAME] = onoff_handler
    },
    [caps.refresh.ID] = {
      [caps.refresh.commands.refresh.NAME] = function(driver, device)
        device:refresh()
      end
    }
  },
}

return controller_subdriver
