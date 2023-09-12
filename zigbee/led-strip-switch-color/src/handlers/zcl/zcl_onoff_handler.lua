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
local st_switch = require "st.capabilities".switch


local function zcl_onoff_handler(_, device, command, zb_rx)
  local onoff = command.value and st_switch.switch.on() or st_switch.switch.off()

  assert(pcall(
    device.emit_event,
    device,
    onoff
  ))
end


return zcl_onoff_handler
