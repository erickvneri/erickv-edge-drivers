-- Copyright 2023 erickvneri
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
local ZigbeeDriver = require "st.zigbee"

-- Zigbee clusters
local zcl_on_off = require "st.zigbee.zcl.clusters".OnOff
local zcl_level = require "st.zigbee.zcl.clusters".Level
local zcl_color_control = require "st.zigbee.zcl.clusters".ColorControl

-- ST capabilities
local st_switch = require "st.capabilities".switch
local st_switch_level = require "st.capabilities".switchLevel
local st_color_control = require "st.capabilities".colorControl
local st_color_temperature = require "st.capabilities".colorTemperature
local st_refresh = require "st.capabilities".refresh

-- Lifecycle handlers
local do_configure = require "lifecycles".do_configure

-- Zigbee handlers
local zcl_onoff_handler = require "handlers.zcl".zcl_onoff_handler
local zcl_level_handler = require "handlers.zcl".zcl_level_handler
local zcl_hue_saturation_handler = require "handlers.zcl".zcl_hue_saturation_handler

-- Capability handlers
local st_switch_handler = require "handlers.st".st_switch_handler
local st_switch_level_handler = require "handlers.st".st_switch_level_handler
local st_refresh_handler = require "handlers.st".st_refresh_handler
local st_color_control_handler = require "handlers.st".st_color_control_handler


local config = {
  supported_capabilities = {
    st_switch,
    st_switch_level,
    st_color_control,
    st_color_temperature

  },
  lifecycle_handlers = {
    added = nil,
    doConfigure = do_configure
  },
  zigbee_handlers = {
    attr = {
      -- OnOff / Switch
      [zcl_on_off.ID] = {
        [zcl_on_off.attributes.OnOff.ID] = zcl_onoff_handler
      },
      -- Level / Switch Level
      [zcl_level.ID] = {
        [zcl_level.attributes.CurrentLevel.ID] = zcl_level_handler
      },
      -- ColorControl / ColorControl.hue
      [zcl_color_control.ID] = {
        [zcl_color_control.attributes.CurrentHue.ID] = zcl_hue_saturation_handler
      },
      -- ColorControl / ColorControl.saturation
      [zcl_color_control.ID] = {
        [zcl_color_control.attributes.CurrentSaturation.ID] = zcl_hue_saturation_handler
      }
    }
  },
  capability_handlers = {
    -- Switch
    [st_switch.ID] = {
      [st_switch.switch.on.NAME] = st_switch_handler,
      [st_switch.switch.off.NAME] = st_switch_handler
    },
    -- Switch Level
    [st_switch_level.ID] = {
      [st_switch_level.commands.setLevel.NAME] = st_switch_level_handler
    },
    -- Refresh
    [st_refresh.ID] = {
      [st_refresh.commands.refresh.NAME] = st_refresh_handler
    },
    -- Color Control
    [st_color_control.ID] = {
      [st_color_control.commands.setColor.NAME] = st_color_control_handler
    }
  }
}


local driver = ZigbeeDriver("zigbee-led-strip-v1.0.0", config)
driver:run()
