local clusters = require 'st.zigbee.zcl.clusters'
local OnOff = clusters.OnOff
local ElectricalMeasurement = clusters.ElectricalMeasurement

local caps = require 'st.capabilities'
local log = require 'log'


---------------------------
---- SUPPORTED DEVICES ----
local SUPPORTED_FINGERPRINTS = {
  { mn='Samjin', model='outlet' },
  { mn='SONOFF', model='S31 Lite zb' }
}


------------------------------
---- OAuth-like interface ----
local function is_supported (opts, driver, device)
  local mn = device:get_manufacturer()
  local model = device:get_model()
  log.info('>> [VALIDATE FINGERPRINT] Manufacturer: '..mn..', Model: '..model)

  for _, fingerprint in ipairs(SUPPORTED_FINGERPRINTS) do
    if mn == fingerprint.mn then
      if model == fingerprint.model then
        log.info('>> [SUCCESS] Fingerprint supported')
        return true
      end
    end
  end
  log.error('>> [ERROR] Fingerprint not supported - unpair device and try again')
  return false
end


--------------------------------------
---- Device Capability Controllers ----
local function onoff_handler(_, device, command)
  log.debug('>> [APP_REPORT] OnOff ZigbeeMessageTx sent')

  local endpoint = device:get_endpoint_for_component_id(command.component)

  if command.command == 'on' then
    device:emit_event_for_endpoint(endpoint, caps.switch.switch.on())
    device:send(OnOff.server.commands.On(device):to_endpoint(endpoint))
    return
  end
  device:emit_event_for_endpoint(endpoint, caps.switch.switch.off())
  device:send(OnOff.server.commands.Off(device):to_endpoint(endpoint))
  return
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
  local endpoint = zb_rx.address_header.src_endpoint.value
  --local endpoint = device:get_endpoint_for_component_id('power')

  -- Platform event
  device:emit_event_for_endpoint(endpoint, caps.powerMeter.power(command.value / 10))
end


------------------------------
---- Controller SubDriver ----
local controller_subdriver = {
  NAME = 'controller',
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
      [caps.refresh.commands.refresh.NAME] = function(_, device)
        device:refresh()
      end
    }
  },
}

return controller_subdriver
