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
local build_cluster_attribute = require "st.zigbee.cluster_base".build_cluster_attribute
local Basic = require "st.zigbee.zcl.clusters".Basic
local Enum8 = require "st.zigbee.data_types".Enum8
local UnknownBasicAttrId = 0xFFFE
local UnknownBasicAttrLabel = "UnknownBasicTuyaAttr"


-- returns prebuilt attribute
-- on top of Basic (0x0000) cluster
return assert(
  build_cluster_attribute(
  Basic,
  UnknownBasicAttrId,
  UnknownBasicAttrLabel,
  Enum8,
  false))