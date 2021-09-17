local clusters = require 'st.zigbee.zcl.clusters'
local OnOff = clusters.OnOff
local SimpleMetering = clusters.SimpleMetering
local PowerConfiguration = clusters.PowerConfiguration

local data_types = require 'st.zigbee.data_types'
local caps = require 'st.capabilities'
local log = require 'log'

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
  --log.info('>> DRIVER ASSIGNATION')
  --log.info('>> DEVICE MANUFACTURER:  '..device:get_manufacturer())
  --log.info('>> DEVICE MODEL:         '..device:get_model())

  for _, fingerprint in ipairs(SUPPORTED_FINGERPRINTS) do
    if device:get_manufacturer() == fingerprint.mn then
      if device:get_model() == fingerprint.model then
        --log.info('>> [SUCCESS] FINGERPRINT SUPPORTED')
        return true
      end
    end
  end
  log.error('>> [ERROR] FINGERPRINT NOT SUPPORTED')
  return false
end


--------------------------------------
---- Device Capability Controlers ----
local function onoff_handler(driver, device, command)
  log.debug('>> ONOFF_HANDLER CALLED')

  local endpoint = device:get_endpoint_for_component_id(command.component)

  pprint(command)
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

local function handle_onoff_update(_, device, command, zb_rx)
  log.debug('>> [OnOff] ZigbeeMessageRx')
  local endpoint = zb_rx.address_header.src_endpoint.value
  local onoff = command.value and caps.switch.switch.on() or caps.switch.switch.off()

  -- Platform event
  device:emit_event_for_endpoint(endpoint, onoff)
end


---------------------------------------------
---- Controller SubDriver & Configuration----
local onoff_cluster_config = {
  cluster=OnOff.ID,
  attribute=OnOff.attributes.OnOff.ID,
  minimum_interval=0,
  maximum_interval=300,
  data_type=data_types.Boolean,
  monitored=true
}

local controller_subdriver = {
  NAME = 'controller',
  cluster_configuration = {
    [caps.switch.ID] = onoff_cluster_config
  },
  can_handle = is_supported,
  zigbee_handlers = {
    attr = {
      -- Switch
      [OnOff.ID] = {
        [OnOff.attributes.OnOff.ID] = handle_onoff_update
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
