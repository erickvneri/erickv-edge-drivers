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
local st_switch = require "st.capabilities".switch


local function st_switch_handler(_, device, command)
  local zcl_attr = zcl_on_off.server.commands
  local onoff = command.command == "on" and zcl_attr.On or zcl_attr.Off
  local st_onoff = command.command == "on" and st_switch.switch.on() or st_switch.switch.off()

  -- Emit at zigbee network
  assert(pcall(
    device.send, device, onoff(device)
  ))

  device:emit_event(st_onoff)
end


return st_switch_handler
