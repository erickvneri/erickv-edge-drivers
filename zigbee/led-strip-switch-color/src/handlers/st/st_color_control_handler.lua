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
local st_color_control = require "st.capabilities".colorControl
local zcl_color_control = require "st.zigbee.zcl.clusters".ColorControl


local function st_color_control_handler(_, device, command)
  local st_hue = command.args.color.hue
  local st_saturation = command.args.color.saturation
  local zcl_hue = math.floor((st_hue * 0xFE) / 100 + 0.5)
  local zcl_saturation = math.floor((st_saturation * 0xFE) / 100 + 0.5)
  local transition_time = device.preferences.transitionTime * 10
  local zcl_cmd = zcl_color_control.server.commands

  -- Zigbee event
  device:send(zcl_cmd.MoveToHueAndSaturation(device, zcl_hue, zcl_saturation, transition_time))
  -- ST Edge event
  device:emit_event(st_color_control.hue(st_hue))
  device:emit_event(st_color_control.saturation(st_saturation))
end


return st_color_control_handler
