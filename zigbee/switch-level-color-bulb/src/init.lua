local caps = require 'st.capabilities'
local ZigbeeDriver = require 'st.zigbee'
local clusters = require 'st.zigbee.zcl.clusters'
local OnOff = clusters.OnOff
local Level = clusters.Level
-- local modules
local do_configure = require 'lifecycles'.do_configure
local device_init = require 'lifecycles'.device_init
local controller = require 'controller'


--------------------------- Driver Setup ---------------------------
local driver_config = {
  supported_capabilities = {
    caps.switch,
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
      -- SwitchLevel
      [Level.ID] = {
        [Level.attributes.CurrentLevel.ID] = controller.handle_current_level_remote
      }
    }
  },
  capability_handlers = {
    [caps.switch.ID] = {
      [caps.switch.commands.on.NAME] = controller.onoff_handler,
      [caps.switch.commands.off.NAME] = controller.onoff_handler
    },
    [caps.switchLevel.ID] = {
      [caps.switchLevel.commands.setLevel.NAME] = controller.level_handler
    },
    [caps.refresh.ID] = {
      [caps.refresh.commands.refresh.NAME] = function(_, device)
        device:refresh()
        device:send(Level.attributes.CurrentLevel:read(device))
      end
    }
  }
}


local driver = ZigbeeDriver("switch_level_color", driver_config)
driver:run()
