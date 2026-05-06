import { WebPlugin } from '@capacitor/core';

import type { GetReferrerResult, InstallReferrerPlugin, PluginVersionResult } from './definitions';

export class InstallReferrerWeb extends WebPlugin implements InstallReferrerPlugin {
  async getReferrer(): Promise<GetReferrerResult> {
    throw this.unavailable('Install referrer is only available on native iOS and Android.');
  }

  async GetReferrer(): Promise<GetReferrerResult> {
    return this.getReferrer();
  }

  async getPluginVersion(): Promise<PluginVersionResult> {
    return {
      version: 'web',
    };
  }
}
