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
local OnOff = require "st.zigbee.zcl.clusters".OnOff
local BuildClusterAttribute = require "st.zigbee.cluster_base".build_cluster_attribute
local Enum8 = require "st.zigbee.data_types".Enum8
local OnOffButtonAttr = 0x8004
local OnOffButtonAttrLabel = "OnOffButton"

-- returns prebuilt attribute
-- on top of OnOff (0x0006) cluster
-- which is used by device to emit
-- button-specific events.
return assert(
  BuildClusterAttribute(
  OnOff,                -- cluster
  OnOffButtonAttr,      -- attr_id
  OnOffButtonAttrLabel, -- attr_name
  Enum8,                -- data_type
  true))                -- is_writable