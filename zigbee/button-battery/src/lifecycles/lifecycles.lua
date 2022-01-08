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


local function _component_to_endpoint(device, component_id)
    local ep = component_id:match("button(%d)")
    return ep and tonumber(ep) or 1
end

local function _endpoint_to_component(_, ep)
  return tonumber(ep) == 1 and 'main' or 'button'..ep
end


-- init lifecycle
--
-- handler component vs endpoint
-- configuration for consistency
local function init(_, device)
  device:set_component_to_endpoint_fn(_component_to_endpoint)
  device:set_endpoint_to_component_fn(_endpoint_to_component)
end


-- added lifecycle
--
-- handles initual
-- state configuration
local function added(driver, device)
  local number_of_buttons = device:component_count()
  for ep=1, number_of_buttons do
    device:emit_event(caps.button.numberOfButtons({ value=number_of_buttons }))
    device:emit_event_for_endpoint(
      ep, caps.button.supportedButtonValues({ "pushed", "double", "held" }))
  end
end


-- doConfigure lifecycle
--
-- handles cluster attribute
-- configuration of report and
-- request binding
local function do_configure(driver, added)

end


return {
  init=init,
  added=added,
  do_configure=do_configure
}
