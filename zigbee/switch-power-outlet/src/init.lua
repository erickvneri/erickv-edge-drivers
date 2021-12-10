local caps = require 'st.capabilities'
local ZigbeeDriver = require 'st.zigbee'
--
-- lifecycle_handlers
local do_configure = require 'lifecycles'.do_configure
local device_init = require 'lifecycles'.device_init


--------------------------- Driver Setup ---------------------------
local zigbee_switch_power_template = {
  supported_capabilities = {
    caps.switch,
    caps.powerMeter
  },
  lifecycle_handlers = {
    init = device_init,
    doConfigure = do_configure
  },
  sub_drivers = { require('controller') },
}

local zigbee_switch_power_driver =
  ZigbeeDriver("switch_power_outlet", zigbee_switch_power_template)

-------------------------- Driver Execute --------------------------
zigbee_switch_power_driver:run()
