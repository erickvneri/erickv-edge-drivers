# Zigbee Drivers for SmartThings Edge

The majority of the *SmartThings Edge Drivers* that are supported at this repository were developed and tested on devices that are already compatible with *SmartThings*, with the exception of the [button-battery](./button-battery) driver that integrates a non-certified Tuya product into the _SmartThings Ecosystem_.

If your device isn't supported and you want to contribute to this repository, you can either submit a _Pull Request_ or you can find me at [SmartThingsCommunity](https://community.smartthings.com/u/erickv/).


## Devices Supported & Features

- [button-battery](./button-battery)




---

```
st edge:drivers:package

st edge:drivers:publish 3b9ee17e-e2ce-417f-b10d-d301bba142d8 --channel 3d97ad69-6423-4f2a-b01b-2c9acf00310f

st edge:drivers:install 3b9ee17e-e2ce-417f-b10d-d301bba142d8 --channel 3d97ad69-6423-4f2a-b01b-2c9acf00310f --hub dd22d8c5-8aa8-44ce-a60b-eb63056e15a9

st edge:drivers:logcat 3b9ee17e-e2ce-417f-b10d-d301bba142d8 --hub-address 192.168.1.66
```