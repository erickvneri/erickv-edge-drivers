# Zigbee Drivers for SmartThings Edge

The majority of the *SmartThings Edge Drivers* that are supported at this repository were developed and tested on devices that are already compatible with *SmartThings*, with the exception of the [button-battery](./button-battery) driver that integrates a non-certified Tuya product into the _SmartThings Ecosystem_.

If your device isn't supported and you want to contribute to this repository, you can either submit a _Pull Request_ or you can find me at [SmartThingsCommunity](https://community.smartthings.com/u/erickv/).

**These drivers are available at the **[@erickv Shared Drivers](https://api.smartthings.com/invite/Q1jP18n4oZML)** channel.**

---

## Drivers

### [button-battery](./button-battery)


```yaml
zigbeeManufacturer:
  # 4-gang MOES Scene Switch
  manufacturer: "_TZ3000_xabckq1v"
  model: "TS004F"
```
**Note**: This Edge driver was initially created to integrate a [4-gang MOES Scene Switch](https://es.aliexpress.com/item/1005001490468150.html?spm=a2g0o.productlist.0.0.30b57d144tWeK1&algo_pvid=2bf0c543-688c-4fc8-a087-e61d67a064a3&algo_exp_id=2bf0c543-688c-4fc8-a087-e61d67a064a3-3&pdp_ext_f=%7B%22sku_id%22%3A%2212000016323568282%22%7D&pdp_pi=-1%3B13.93%3B-1%3BUSD+1.31%40salePrice%3BUSD%3Bsearch-mainSearch).

### Features:

- 3 Button states *(pushed, double, held)* on every button differentiated by components.
- The **battery level** is handled by the `main` component and is being **refreshed every hour** or by **pressing button no.2**.
