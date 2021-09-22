local data_types = require 'st.zigbee.data_types'
local clusters = require 'st.zigbee.zcl.clusters'
local OnOff = clusters.OnOff
local ElectricalMeasurement = clusters.ElectricalMeasurement


-- [[
--   Reporting Configuration for supported
--   Zigbee attributes:
--     - OnOff (OnOff)
--     - ElectricalMeasurement (ActivePower)
-- ]]
local onoff_cluster_config = {
  cluster=OnOff.ID,
  attribute=OnOff.attributes.OnOff.ID,
  minimum_interval=0,
  maximum_interval=300,
  monitored=true
}

local power_cluster_config = {
  cluster=ElectricalMeasurement.ID,
  attribute=ElectricalMeasurement.attributes.ActivePower.ID,
  minimum_interval=0,
  maximum_interval=300,
  data_type=1,
  monitored=true
}

return {
  onoff_cluster_config=onoff_cluster_config,
  power_cluster_config=power_cluster_config
}
