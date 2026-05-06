# AGENTS.md

This file provides guidance to AI agents and contributors working on this Capacitor plugin.

## Quick Start

~~~bash
bun install
bun run build
bun run verify
bun run fmt
bun run lint
~~~

## Development Workflow

1. Install dependencies with bun install. Never use npm.
2. Build with bun run build. This compiles TypeScript, runs docgen, and bundles Rollup output.
3. Verify with bun run verify before submitting work.
4. Format with bun run fmt and lint with bun run lint.

### Individual Platform Verification

~~~bash
bun run verify:ios
bun run verify:android
bun run verify:web
~~~

### Example App

The example app references the plugin through file:...

~~~bash
cd example-app
bun install
bun run start
~~~

Use bunx cap sync ios or bunx cap sync android for native shells.

## Project Structure

- src/definitions.ts - TypeScript interfaces and the source of truth for generated API docs
- src/index.ts - Plugin registration
- src/web.ts - Web implementation
- ios/Sources/ - iOS native code using Apple AdServices
- android/src/main/ - Android native code using Google Play Install Referrer
- dist/ - Generated output, do not edit manually
- Package.swift - SwiftPM definition
- CapgoCapacitorInstallReferrer.podspec - CocoaPods spec

## Plugin Notes

- Android uses com.android.installreferrer:installreferrer and must close the client connection after each request.
- iOS cannot read a generic App Store referrer. Use Apple AdServices attribution tokens and optional Apple attribution lookup.
- Keep GetReferrer as a compatibility alias for users migrating from cap-play-install-referrer.
- Web should reject install referrer reads because no browser equivalent exists.

## API Documentation

API docs in README.md are auto-generated from JSDoc in src/definitions.ts. Do not edit the docgen sections directly. Update src/definitions.ts and run bun run docgen or bun run build.

## Versioning

The plugin major version follows the Capacitor major version. Avoid breaking changes outside a Capacitor major migration.

## Changelog

CHANGELOG.md is managed automatically by CI/CD. Do not edit it manually.

## Common Pitfalls

- Keep CocoaPods and SwiftPM support working.
- Keep Android on Java 21.
- Do not edit dist manually.
- Use Bun for every package command. Use bunx instead of npx.
