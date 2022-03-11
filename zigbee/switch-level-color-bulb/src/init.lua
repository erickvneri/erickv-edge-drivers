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
local caps = require 'st.capabilities'
local ZigbeeDriver = require 'st.zigbee'
local clusters = require 'st.zigbee.zcl.clusters'
local OnOff = clusters.OnOff
local Level = clusters.Level
-- local modules
local do_configure = require 'lifecycles'.do_configure
local device_init = require 'lifecycles'.device_init
local info_changed = require 'lifecycles'.info_changed
local controller = require 'controller'


--------------------------- Driver Setup ---------------------------
local driver_config = {
  supported_capabilities = {
    caps.switch,
  },
  lifecycle_handlers = {
    init = device_init,
    doConfigure = do_configure,
    infoChanged = info_changed
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


local driver = ZigbeeDriver("switch-level-v1.2.0", driver_config)
driver:run()
