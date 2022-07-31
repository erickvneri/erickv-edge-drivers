# Tuya TS004F SmartKnob Zigbee Edge Driver

This Driver extends the functionality of the **Tuya TS004F SmartKnob**
end-device that the previous [button-battery](https://github.com/erickvneri/erickv-edge-drivers/tree/main/zigbee/button-battery) Driver provides, providing enhanced device interoperability
by providing control over other capabilities such as:

- [Thermostat Cooling Setpoint](https://developer-preview.smartthings.com/docs/devices/capabilities/capabilities-reference#thermostatCoolingSetpoint)
- [Window Shade](https://developer-preview.smartthings.com/docs/devices/capabilities/capabilities-reference#windowShade)
- [Lock](https://developer-preview.smartthings.com/docs/devices/capabilities/capabilities-reference)
- etc.

Needles to say, it will keep supporting the previous features, such
as switching operating mode into DIMMER mode broadcasting **On/Off**
and **Level** commands through the **Zigbe Groups** cluster.

---

## Change log

### **release-v1.0.0**
- Support of rotation options:
  - DEFAULT _(enables Rotation custom capability)_
  - LEVEL
  - COOLING_SETPOINT
  - HEATING_SETPOINT
  - LOCK
  - WINDOW_SHADE
- Dynamic profiles based on rotation option.
- Configurable direction for action.

---

## Issues

**About device metadata**

It is well known that **constant metadata updates** may result
in not having the expected interface at the SmartThings App, hence, every rotation option provides its own capability-related preferences,
i.e. if the app doesn't show the capability card into Detail View,
the user will have the chance to set the state through the Settings
page.
