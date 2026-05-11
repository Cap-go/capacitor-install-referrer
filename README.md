# @capgo/capacitor-install-referrer
<a href="https://capgo.app/"><img src="https://capgo.app/readme-banner.svg?repo=Cap-go/capacitor-install-referrer" alt="Capgo - Instant updates for Capacitor" /></a>

<div align="center">
  <h2><a href="https://capgo.app/?ref=plugin_install_referrer">➡️ Ship Instant Updates with Capgo</a></h2>
  <h2><a href="https://capgo.app/consulting/?ref=plugin_install_referrer">Missing a feature? We’ll build the plugin for you 💪</a></h2>
</div>

Capacitor plugin for install attribution. Android reads Google Play Install Referrer, and iOS uses Apple AdServices attribution tokens with optional Apple Search Ads attribution lookup.

Compatible with Capacitor 8.

## Platform behavior

- Android returns the Play install referrer string, click timestamp, install timestamp, and instant experience flag.
- iOS returns an AdServices attribution token. Set fetchAppleAttribution to true to ask Apple for the attribution payload directly from native code.
- iOS does not provide a generic App Store install referrer equivalent to Google Play. Apple AdServices covers Apple Search Ads attribution.
- Web is unavailable and rejects the call.

## Install

~~~bash
bun add @capgo/capacitor-install-referrer
bunx cap sync
~~~

## Usage

~~~ts
import { InstallReferrer } from '@capgo/capacitor-install-referrer';

const result = await InstallReferrer.getReferrer();

if (result.platform === 'android') {
  console.log(result.referrer);
}

if (result.platform === 'ios') {
  console.log(result.attributionToken);
}
~~~

Fetch the Apple attribution payload from iOS native code:

~~~ts
const result = await InstallReferrer.getReferrer({
  fetchAppleAttribution: true,
  appleAttributionRetryCount: 3,
  appleAttributionRetryDelayMs: 5000,
});

console.log(result.appleAttribution);
~~~

GetReferrer() is also available as a deprecated compatibility alias for apps migrating from cap-play-install-referrer.

## Compatibility

| Plugin version | Capacitor compatibility | Maintained |
| -------------- | ----------------------- | ---------- |
| v8.*.*         | v8.*.*                  | Yes        |
| v7.*.*         | v7.*.*                  | On demand  |
| v6.*.*         | v6.*.*                  | No         |

## API

<docgen-index>

* [`getReferrer(...)`](#getreferrer)
* [`GetReferrer(...)`](#getreferrer)
* [`getPluginVersion()`](#getpluginversion)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

Base API for retrieving install referrer and attribution details.

### getReferrer(...)

```typescript
getReferrer(options?: GetReferrerOptions | undefined) => Promise<GetReferrerResult>
```

Returns native install attribution details.

Android reads the Google Play Install Referrer API.
iOS returns an Apple AdServices attribution token and can optionally fetch Apple's attribution payload.

| Param         | Type                                                              |
| ------------- | ----------------------------------------------------------------- |
| **`options`** | <code><a href="#getreferreroptions">GetReferrerOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#getreferrerresult">GetReferrerResult</a>&gt;</code>

**Since:** 8.0.0

--------------------


### GetReferrer(...)

```typescript
GetReferrer(options?: GetReferrerOptions | undefined) => Promise<GetReferrerResult>
```

Backward-compatible alias for plugins inspired by cap-play-install-referrer.

| Param         | Type                                                              |
| ------------- | ----------------------------------------------------------------- |
| **`options`** | <code><a href="#getreferreroptions">GetReferrerOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#getreferrerresult">GetReferrerResult</a>&gt;</code>

**Since:** 8.0.0

--------------------


### getPluginVersion()

```typescript
getPluginVersion() => Promise<PluginVersionResult>
```

Returns the platform implementation version marker.

**Returns:** <code>Promise&lt;<a href="#pluginversionresult">PluginVersionResult</a>&gt;</code>

**Since:** 8.0.0

--------------------


### Interfaces


#### GetReferrerResult

Install referrer and attribution details returned by the native platform.

| Prop                               | Type                                                                      | Description                                                                                                                   | Since |
| ---------------------------------- | ------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ----- |
| **`platform`**                     | <code>string</code>                                                       | Platform that produced the result. Android returns android; iOS returns ios.                                                  | 8.0.0 |
| **`referrer`**                     | <code>string</code>                                                       | Android only. Raw Google Play install referrer string.                                                                        | 8.0.0 |
| **`clickTimestampSeconds`**        | <code>number</code>                                                       | Android only. Client-side click timestamp in seconds.                                                                         | 8.0.0 |
| **`installBeginTimestampSeconds`** | <code>number</code>                                                       | Android only. Client-side install begin timestamp in seconds.                                                                 | 8.0.0 |
| **`googlePlayInstantParam`**       | <code>boolean</code>                                                      | Android only. True when the user launched your app's instant experience.                                                      | 8.0.0 |
| **`attributionToken`**             | <code>string</code>                                                       | iOS only. Apple AdServices attribution token. Send this token to your backend, MMP, or Apple's AdServices API within its TTL. | 8.0.0 |
| **`appleAttribution`**             | <code><a href="#appleattributionrecord">AppleAttributionRecord</a></code> | iOS only. Apple AdServices attribution payload when fetchAppleAttribution is true.                                            | 8.0.0 |


#### AppleAttributionRecord

Install attribution values returned by Apple AdServices.

Apple may add fields over time, so unknown keys are preserved.

| Prop              | Type                 | Description                                                           | Since |
| ----------------- | -------------------- | --------------------------------------------------------------------- | ----- |
| **`attribution`** | <code>boolean</code> | True when Apple found a matching Apple Search Ads attribution record. | 8.0.0 |


#### GetReferrerOptions

Options for reading install attribution.

| Prop                               | Type                 | Description                                                                                                                                                                                                                  | Default            | Since |
| ---------------------------------- | -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------ | ----- |
| **`fetchAppleAttribution`**        | <code>boolean</code> | iOS only. When true, the plugin sends the AdServices attribution token to Apple and returns the attribution payload in appleAttribution. Leave this false when you want to send attributionToken to your own backend or MMP. | <code>false</code> | 8.0.0 |
| **`appleAttributionRetryCount`**   | <code>number</code>  | iOS only. Number of times to retry Apple's attribution endpoint after a 404 response. Apple can return 404 when the token is valid but attribution data is not ready yet.                                                    | <code>3</code>     | 8.0.0 |
| **`appleAttributionRetryDelayMs`** | <code>number</code>  | iOS only. Delay between Apple attribution retries, in milliseconds.                                                                                                                                                          | <code>5000</code>  | 8.0.0 |


#### PluginVersionResult

Plugin version payload.

| Prop          | Type                | Description                                                 |
| ------------- | ------------------- | ----------------------------------------------------------- |
| **`version`** | <code>string</code> | Version identifier returned by the platform implementation. |

</docgen-api>
