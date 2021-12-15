# Edge Driver for Zigbee-based Bulbs

### Devices supported

1. Sengled Bulb _(E11-G13)_

### Regarding Clusters and Capabilities

- Switch

  Some interesting information regarding extended functionalities based on the
  OnOff cluster

- Switch Level

  The most interesting feature that can be programmed via user-defined preferences
  is the `transition_time` parameter that the `Level.MoveToLevel` cluster command
  accepts. And it defines the time-lapse that it will take the device to change from
  the **current level state** to the **latest level state** _(this can be overriden on-demand)_.
