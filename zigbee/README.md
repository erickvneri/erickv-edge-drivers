# Zigbee Drivers for SmartThings Edge

The majority of the *SmartThings Edge Drivers* that are supported at this repository were developed and tested on devices that are already compatible with *SmartThings*, with the exception of the [button-battery](./button-battery) driver that integrates a non-certified Tuya product into the _SmartThings Ecosystem_.

If your device isn't supported and you want to contribute to this repository, you can either submit a _Pull Request_ or you can find me at [SmartThingsCommunity](https://community.smartthings.com/u/erickv/).

**These drivers are available at the **[@erickv Shared Drivers](https://api.smartthings.com/invite/Q1jP18n4oZML)** channel.**

_(**Note**: You can also find in-develop edge drivers at **[dev-@erickv Shared Drivers](https://api.smartthings.com/invite/pbMvQvqgpGjO)** channel.)_

---

## Drivers

### [button-battery](./button-battery)
```yaml
zigbeeManufacturer:
  # MOES 4-Button Scene Switch
  manufacturer: "_TZ3000_xabckq1v"
  model: "TS004F"

  # MOES 3-Button Scene Switch   (SUCCESS TBD)
  manufacturer: "_TZ3000_gbm10jnj"
  model: "TS0043"

  # MOES 3-Button Scene Switch (alt)
  manufacturer: "_TZ3000_w8jwkczz"
  model: "TS0043"

  # MOES 2-Button Scene Switch
  manufacturer: "_TZ3000_dfgbtub0"
  model: "TS0042"

  # Modmote TS004F variation
  manufacturer: "_TZ3000_czuyt8lz"
  model: "TS004F"

  # Eardatek 4-Button Remote
  manufacturer: "_TZ3000_vp6clf9d"
  model: "TS0044"

  # LoraTap 3-Button Remote
  manufacturer: "_TZ3000_bi6lpsew"
  model: "TS0043"

  # LoraTap 4-Button Remote
  manufacturer: "_TZ3000_ee8nrt2l"
  model: "TS0044"

  # "Yagusmart" 1-Button In Wall Switch
  manufacturer: "_TZ3000_m0btfbt7"
  model: "TS0001"

  # "Yagusmart" 2-Button Scene Switch
  manufacturer: "_TZ3000_fvh3pjaz"
  model: "TS0012"

  # "Yagusmart" 4-Button Scene Switch
  manufacturer: "_TZ3000_wkai4ga5"
  model: "TS0044"

  # Smart Knob
  manufacturer: "_TZ3000_4fjiwweb"
  model: "TS004F"
```
_(to get the full list of supported devices, refer to [fingerprints.yaml](./button-battery/fingerprints.yaml))_

### [switch-level-color-bulb](./switch-level-color-bulb)
```yaml
zigbeeManufacturer:
  # Sengled Soft White Bulb
  manufacturer: "sengled"
  model: "E11-G13"
```

### [switch-power-outlet](./switch-power-outlet)
```yaml
zigbeeManufacturer:
  # Samjin/SmartThings Outlet
    manufacturer: "Samjin"
    model: "outlet"

  # Sonoff Outlet
    manufacturer: "SONOFF"
    model: "S31 Lite zb"
```

---

## Acknowledgements

Special thanks to the members of the _SmartThings Community_ that not only helped me to
clarify a lot of Zigbee-specific concepts and inquiries, but also those that made this _Edge
Driver_ much more reusable and important that I was expecting. Again many thanks guys!

### Donations

Only if you're able and consider that you'd like to donate to this project, I'd appreciate it
a lot, since we all know that most of the times free software is developed on our free time
and not as a job per se.
So, in case you'd like to donate, you can share some ether to

```
0xEf5e2a96593376C9b9E488CA27458Ad070f30cBE
```
