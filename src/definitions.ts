/**
 * Plugin version payload.
 */
export interface PluginVersionResult {
  /**
   * Version identifier returned by the platform implementation.
   */
  version: string;
}

/**
 * Options for reading install attribution.
 */
export interface GetReferrerOptions {
  /**
   * iOS only. When true, the plugin sends the AdServices attribution token to Apple and returns
   * the attribution payload in appleAttribution.
   *
   * Leave this false when you want to send attributionToken to your own backend or MMP.
   *
   * @default false
   * @since 8.0.0
   */
  fetchAppleAttribution?: boolean;

  /**
   * iOS only. Number of times to retry Apple's attribution endpoint after a 404 response.
   *
   * Apple can return 404 when the token is valid but attribution data is not ready yet.
   *
   * @default 3
   * @since 8.0.0
   */
  appleAttributionRetryCount?: number;

  /**
   * iOS only. Delay between Apple attribution retries, in milliseconds.
   *
   * @default 5000
   * @since 8.0.0
   */
  appleAttributionRetryDelayMs?: number;
}

/**
 * Install attribution values returned by Apple AdServices.
 *
 * Apple may add fields over time, so unknown keys are preserved.
 */
export interface AppleAttributionRecord {
  /**
   * True when Apple found a matching Apple Search Ads attribution record.
   *
   * @since 8.0.0
   */
  attribution?: boolean;

  /**
   * Additional fields returned by Apple AdServices.
   *
   * @since 8.0.0
   */
  [key: string]: string | number | boolean | null | undefined;
}

/**
 * Install referrer and attribution details returned by the native platform.
 */
export interface GetReferrerResult {
  /**
   * Platform that produced the result.
   *
   * Android returns android; iOS returns ios.
   *
   * @since 8.0.0
   */
  platform: string;

  /**
   * Android only. Raw Google Play install referrer string.
   *
   * @since 8.0.0
   */
  referrer?: string;

  /**
   * Android only. Client-side click timestamp in seconds.
   *
   * @since 8.0.0
   */
  clickTimestampSeconds?: number;

  /**
   * Android only. Client-side install begin timestamp in seconds.
   *
   * @since 8.0.0
   */
  installBeginTimestampSeconds?: number;

  /**
   * Android only. True when the user launched your app's instant experience.
   *
   * @since 8.0.0
   */
  googlePlayInstantParam?: boolean;

  /**
   * iOS only. Apple AdServices attribution token.
   *
   * Send this token to your backend, MMP, or Apple's AdServices API within its TTL.
   *
   * @since 8.0.0
   */
  attributionToken?: string;

  /**
   * iOS only. Apple AdServices attribution payload when fetchAppleAttribution is true.
   *
   * @since 8.0.0
   */
  appleAttribution?: AppleAttributionRecord;
}

/**
 * Base API for retrieving install referrer and attribution details.
 */
export interface InstallReferrerPlugin {
  /**
   * Returns native install attribution details.
   *
   * Android reads the Google Play Install Referrer API.
   * iOS returns an Apple AdServices attribution token and can optionally fetch Apple's attribution payload.
   *
   * @since 8.0.0
   */
  getReferrer(options?: GetReferrerOptions): Promise<GetReferrerResult>;

  /**
   * Backward-compatible alias for plugins inspired by cap-play-install-referrer.
   *
   * @deprecated Use getReferrer.
   * @since 8.0.0
   */
  GetReferrer(options?: GetReferrerOptions): Promise<GetReferrerResult>;

  /**
   * Returns the platform implementation version marker.
   *
   * @since 8.0.0
   */
  getPluginVersion(): Promise<PluginVersionResult>;
}
