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
local zcl_on_off = require "st.zigbee.zcl.clusters".OnOff
local zcl_level = require "st.zigbee.zcl.clusters".Level
local zcl_color_control = require "st.zigbee.zcl.clusters".ColorControl


local function st_refresh_handler(_, device)
  device:send(zcl_on_off.attributes.OnOff:read(device))
  device:send(zcl_level.attributes.CurrentLevel:read(device))
  device:send(zcl_color_control.attributes.CurrentHue:read(device))
  device:send(zcl_color_control.attributes.CurrentSaturation:read(device))
end


return st_refresh_handler
