# SecurePay Frontend

Flutter client (web + mobile) for the SecurePay cross-border shipping and
payments platform. Built with Flutter and the GetX state-management package.

## Features

- Sign up / sign in / email verification screens
- Dashboard with analytics, growth and balances
- Wallet with simulated funding and deposit history
- Create-shipment dialog with live delivery-cost quotes and pay-as-you-create
- Shipments page with search, status/direction filters and pagination
- Shipment tracking page with status timeline and journey stops
- Notifications center

## Prerequisites

- Flutter 3.x with a recent Dart SDK (see `pubspec.yaml`)

## Getting started

```sh
flutter clean
flutter pub get
cp .env.example .env   # set API_BASE_URL (defaults to http://localhost:5001/api)
```

Run on Chrome with the env file baked in:

```sh
flutter run -d chrome --dart-define-from-file=.env
```

Other commands:

```sh
flutter build web --dart-define-from-file=.env   # production web build
flutter test                                     # widget + validation tests
flutter analyze                                  # static analysis
```

## Configuration

The API base URL is read from `API_BASE_URL`, which is compiled into the app
at build time (`lib/core/config.dart`, `ApiConfig.baseUrl`). It can also be
passed directly with `--dart-define=API_BASE_URL=...`. Without either, the app
falls back to `http://localhost:5001/api`.

`.env` values are public (baked into the build) — never put secrets there.

In VS Code, the "SecurePay (Chrome)" launch configuration passes the env file
automatically.

## Monetary units

Amounts come from the API in **kobo** (1/100 of a Naira) and are formatted for
display with `formatNaira(...)` (`lib/utils/formatters.dart`).

## Deploying to Vercel

Vercel can't build Flutter, so the app is built locally and uploaded as a
static site (project `securepay`) using Vercel's Build Output API:

```sh
./deploy_web.sh           # production
./deploy_web.sh preview   # preview URL
```

`API_BASE_URL` in `.env` is baked into the build, so redeploy after changing it.

## Project structure

```
lib/
  bindings/    GetX dependency injection
  controllers/ state controllers (auth, dashboard, wallet, shipments, ...)
  core/        API config
  models/      data models
  screens/     auth + dashboard screens
  services/    HTTP clients
  theme/       colors, typography, themes
  utils/       formatters, feedback helpers
  widgets/     reusable UI (dashboard cards, dialogs, pages)
test/          widget + validation tests
assets/        fonts, icons, images
```

## Tests

- `flutter test` — widget and validation tests (Fake services in
  `test/widget_test.dart`)
- `flutter analyze` — static analysis (must be clean)