# securepay

A new Flutter project.

## Configuration

The API URL is read from `.env` at build time:

```sh
cp .env.example .env        # then edit API_BASE_URL if needed
flutter run -d chrome --dart-define-from-file=.env
flutter build web --dart-define-from-file=.env
```

In VS Code, the "SecurePay (Chrome)" launch configuration passes the file
automatically. Without the flag the app falls back to
`http://localhost:5001/api`.

## Deploying to Vercel

Vercel can't build Flutter, so the app is built locally and uploaded as a
static site (project `securepay`, https://securepay-seven.vercel.app):

```sh
./deploy_web.sh           # production
./deploy_web.sh preview   # preview URL
```

`API_BASE_URL` in `.env` is baked into the build, so redeploy after changing it.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
