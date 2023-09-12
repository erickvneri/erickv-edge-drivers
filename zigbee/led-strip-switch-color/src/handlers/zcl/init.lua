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
local zcl_onoff_handler = require "handlers.zcl.zcl_onoff_handler"
local zcl_level_handler = require "handlers.zcl.zcl_level_handler"
local zcl_hue_saturation_handler = require "handlers.zcl.zcl_hue_saturation_handler"


return {
  zcl_onoff_handler = zcl_onoff_handler,
  zcl_level_handler = zcl_level_handler,
  zcl_hue_saturation_handler = zcl_hue_saturation_handler
}
