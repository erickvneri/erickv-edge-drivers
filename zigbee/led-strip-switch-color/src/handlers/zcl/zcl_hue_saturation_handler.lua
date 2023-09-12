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


local function zcl_hue_saturation_handler(_, device, command, zb_rx)
  local attr = command.field_name
  local hue = 0
  local saturation = 0

  if attr == "CurrentSaturation" then
    saturation = command.value
  elseif attr == "CurrentHue" then
    hue = command.value
  end

  device:emit_event(st_color_control.hue(hue))
  device:emit_event(st_color_control.saturation(saturation))
end


return zcl_hue_saturation_handler
