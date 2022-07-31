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
local cooling_setpoint = require "st.capabilities".thermostatCoolingSetpoint
local heating_setpoint = require "st.capabilities".thermostatHeatingSetpoint
local switch_level = require "st.capabilities".switchLevel
local window_shade = require "st.capabilities".windowShade
local lock = require "st.capabilities".lock
local rotation = require "st.capabilities"["againschool57104.rotation"]

local ZigbeeDriver = require "st.zigbee"
local PowerConfiguration = require "st.zigbee.zcl.clusters".PowerConfiguration
local OnOff = require "st.zigbee.zcl.clusters".OnOff
local OnOffButtonCommandId = 0xFD
local OnOffSmartKnobCommandId = 0xFC

-- local modules
local init = require "lifecycles".init
local added = require "lifecycles".added
local info_changed = require "lifecycles".info_changed
local do_configure = require "lifecycles".do_configure
local emitter = require "emitter"

print(emitter.send_lock_event, lock.commands.lock)
-- Edge Driver Configuration
local driver_config = {
  supported_capabilities = {
    battery,
    button,
    cooling_setpoint,
    heating_setpoint,
    switch_level,
    window_shade,
    lock,
    rotation
  },
  lifecycle_handlers = {
    init = init,
    added = added,
    infoChanged = info_changed,
    doConfigure = do_configure
  },
  capability_handlers = {
    [cooling_setpoint.ID] = {
      [cooling_setpoint.commands.setCoolingSetpoint.NAME] = emitter.send_cooling_setpoint_event
    },
    [heating_setpoint.ID] = {
      [heating_setpoint.commands.setHeatingSetpoint.NAME] = emitter.send_heating_setpoint_event
    },
    [switch_level.ID] = {
      [switch_level.commands.setLevel.NAME] = emitter.send_switch_level_event
    },
    [lock.ID] = {
      [lock.commands.lock.NAME] = emitter.send_lock_event,
      [lock.commands.unlock.NAME] = emitter.send_lock_event
    },
    [window_shade.ID] = {
      [window_shade.commands.open.NAME] = emitter.send_window_shade_event,
      [window_shade.commands.close.NAME] = emitter.send_window_shade_event,
      [window_shade.commands.pause.NAME] = emitter.send_window_shade_event
    }
  },
  zigbee_handlers = {
    attr = {
      [PowerConfiguration.ID] = {
        [PowerConfiguration.attributes.BatteryPercentageRemaining.ID] = emitter.send_battery_level_event
      }
    },
    cluster = {
      [OnOff.ID] = {
        [OnOffButtonCommandId] = emitter.send_button_event,
        [OnOffSmartKnobCommandId] = emitter.send_knob_event
      }
    }
  }
}

local driver = ZigbeeDriver("button-battery-knob-v1.0.0", driver_config)
driver:run()