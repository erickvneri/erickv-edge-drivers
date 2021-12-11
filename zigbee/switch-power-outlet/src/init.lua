local caps = require 'st.capabilities'
local ZigbeeDriver = require 'st.zigbee'
local clusters = require 'st.zigbee.zcl.clusters'
local OnOff = clusters.OnOff
local ElectricalMeasurement = clusters.ElectricalMeasurement

-- local modules
local do_configure = require 'lifecycles'.do_configure
local device_init = require 'lifecycles'.device_init
local controller = require 'controller'

--------------------------- Driver Setup ---------------------------
local driver_config = {
  supported_capabilities = {
    caps.switch,
    caps.powerMeter
  },
  lifecycle_handlers = {
    init = device_init,
    doConfigure = do_configure
  },
  zigbee_handlers = {
    attr = {
      -- Switch
      [OnOff.ID] = {
        [OnOff.attributes.OnOff.ID] = controller.handle_onoff_remote
      },
      -- Power Meter
      [ElectricalMeasurement.ID] = {
        [ElectricalMeasurement.attributes.ActivePower.ID] = controller.handle_power_remote
      }
    }
  },
  capability_handlers = {
    [caps.switch.ID] = {
      [caps.switch.commands.on.NAME] = controller.onoff_handler,
      [caps.switch.commands.off.NAME] = controller.onoff_handler
    },
    [caps.refresh.ID] = {
      [caps.refresh.commands.refresh.NAME] = function(_, device)
        device:refresh()
      end
    }
  }
}

local driver = ZigbeeDriver("switch_power_outlet", driver_config)

-------------------------- Driver Execute --------------------------
driver:run()
