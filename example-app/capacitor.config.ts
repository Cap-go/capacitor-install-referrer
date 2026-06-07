import type { CapacitorConfig } from '@capacitor/cli';

import pkg from './package.json';

const config: CapacitorConfig = {
  "appId": "app.capgo.installreferrer.example",
  "appName": "Install Referrer Example",
  "webDir": "dist",
  "plugins": {
    "CapacitorUpdater": {
      "appId": "app.capgo.installreferrer.example",
      "autoUpdate": true,
      "autoSplashscreen": true,
      "directUpdate": "always",
      "defaultChannel": "production",
      "version": pkg.version
    }
  }
};

export default config;
