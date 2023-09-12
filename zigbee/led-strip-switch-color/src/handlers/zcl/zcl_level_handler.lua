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
local st_switch_level = require "st.capabilities".switchLevel

local function zcl_level_handler(_, device, command, zb_rx)
  local percent = math.floor(((command.value / 0xFF) * 0x64 ) + 0.5)

  assert(pcall(
    device.emit_event,
    device,
    st_switch_level.level({ value = percent })
  ))
end


return zcl_level_handler
