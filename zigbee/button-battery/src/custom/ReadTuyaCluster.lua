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
local read_manufacturer_specific_attribute = require "st.zigbee.cluster_base".read_manufacturer_specific_attribute
local TuyaClusterId = 0xE001
local TuyaClusterAttrId = 0xD011


-- returns formatted ReadAttribute
-- ZigbeeMessageTx from specific
-- device
--
-- @param device ZigbeeDevice
local function ReadTuyaCluster(device)
  return assert(read_manufacturer_specific_attribute(
    device,
    TuyaClusterId,
    TuyaClusterAttrId, 1))
end


return ReadTuyaCluster