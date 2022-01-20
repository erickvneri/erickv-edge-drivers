### Change log

- v1.0.0
  - Integration mirroring default configuration
    that was defined by the DTH.
  - Support for Switch, Switch Level, and Refresh
    capabilities.

- v1.1.0
  - Added support of **Transition Time** at device
    settings *(profile preferences)* to provide dimming
    UX while changing level.
  - This allowed automating long and flowless dimming
    periods.
  - Added support of Transition on Switch to have dimming
    UX while switching On and Off the device.

- v1.1.1
  - Patched Transition Time data type from **Integer** to
    **Number** to allow configuration of decimals and improve
    UX while setting up automations.