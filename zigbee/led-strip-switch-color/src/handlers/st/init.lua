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
local st_switch_handler = require "handlers.st.st_switch_handler"
local st_switch_level_handler = require "handlers.st.st_switch_level_handler"
local st_refresh_handler = require "handlers.st.st_refresh_handler"
local st_color_control_handler = require "handlers.st.st_color_control_handler"


return {
  st_switch_handler = st_switch_handler,
  st_switch_level_handler = st_switch_level_handler,
  st_refresh_handler = st_refresh_handler,
  st_color_control_handler = st_color_control_handler
}
