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
local battery = require "st.capabilities".battery
local button = require "st.capabilities".button

local ZigbeeDriver = require "st.zigbee"
local PowerConfiguration = require "st.zigbee.zcl.clusters".PowerConfiguration
local OnOff = require "st.zigbee.zcl.clusters".OnOff
local OnOffButtonCommandId = 0xFD

-- local modules
local init = require "lifecycles".init
local added = require "lifecycles".added
local do_configure = require "lifecycles".do_configure

local emitter = require "emitter"


-- Edge Driver Configuration
local driver_config = {
  supported_capabilities = {
    battery,
    button
  },
  lifecycle_handlers = {
    init = init,
    added = added,
    doConfigure = do_configure
  },
  zigbee_handlers = {
    attr = {
      [PowerConfiguration.ID] = {
        [PowerConfiguration.attributes.BatteryPercentageRemaining.ID] = emitter.send_battery_level_event
      }
    },
    cluster = {
      [OnOff.ID] = {
        [OnOffButtonCommandId] = emitter.send_button_event
      }
    }
  }
}


local driver = ZigbeeDriver("button-battery-v1.0.1", driver_config)
driver:run()