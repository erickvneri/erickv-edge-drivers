-- MIT License
--
-- Copyright (c) 2021 Erick Israel Vazquez Neri
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
local caps = require 'st.capabilities'
local ZigbeeDriver = require 'st.zigbee'
local clusters = require 'st.zigbee.zcl.clusters'
local PowerConfiguration = clusters.PowerConfiguration

-- local modules
local init = require 'lifecycles'.init
local added = require 'lifecycles'.added
local do_configure = require 'lifecycles'.do_configure
--local cluster_handler = require 'event_handlers'.cluster_handler
--local event_emitter = require 'event_handlers'.emitter


-- Edge Driver Configuration
local driver_config = {
  supported_capabilities = {
    caps.button,
    caps.refresh,
    caps.battery
  },
  lifecycle_handlers = {
    init = init,
    added = added,
    doConfigure = do_configure
  },
  zigbee_handlers = {
    attr = {
      [PowerConfiguration.ID] = {
        [PowerConfiguration.attributes.BatteryPercentageRemaining.ID] = nil
      }
    }
  }
}

local driver = ZigbeeDriver('button-battery', driver_config)
driver:run()
