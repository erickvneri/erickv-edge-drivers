### Change log

> v1.0.0
  - Driver built based on **4-gang MOES Scene Switch**.
  - Support of `pushed`, `double`, and `held` button
    states across 4 device components.
  - Device rendering as `RemoteController` as it provide
    short-hand automations based on `button.supportedButtonValues`.
  - Battery state handled by `main` component.
  - Automatic battery updates every 6 hours.

> v1.0.1
  - Provided support for 3-Button MOES Scene Switch.
  - New multi-component *device profile*.
  - Support for TS004F model variation.
  - Testing support for 3 and 2-Button MOES versions.

> v1.1.0
  - Updated device profile in pro of user experience.
  - Assigned battery capability to "battery" component.
  - Added 2 fingerprints for 3 and 4-button generic devices.

> v1.2.0
  - Added custom presentation reference to all profiles
    which allowed devices to render orderly at `detailView`.
  - Assigned **Battery capability** as dashboard state.
  - Assigned Battery capability to `battery` component.

> v1.3.0
  - New TS0043 alternative fingerprint for the MOES
    3-Button Scene Switch.

> v1.3.1
  - Fixed minimal battery report time from 300s to 3600s
    to avoid battery consumption on not-so-sleepy devices.
  - Patched fingerprint for **Yagusmart** devices.

> v1.3.2
  - Added SmartKnob fingerprint and single-button profile.
  - Added 2-button Loratap fingerprint _(TS0044)_.
  - Added Yagustmart 2-button fingerprint _(TS0012)_.