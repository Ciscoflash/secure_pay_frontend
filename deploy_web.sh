#!/usr/bin/env bash
# Build the Flutter web app and deploy it to Vercel as a static site.
#
# Vercel's build machines don't have Flutter, so we build locally and upload
# the result using Vercel's Build Output API (.vercel/output), which skips the
# remote build step entirely.
#
# Usage:
#   ./deploy_web.sh           # production deployment
#   ./deploy_web.sh preview   # preview deployment (separate URL)
#
# The API URL comes from .env (API_BASE_URL) and is baked into the build.
set -euo pipefail
cd "$(dirname "$0")"

if [[ ! -f .env ]]; then
  echo "Missing .env — copy .env.example to .env and set API_BASE_URL." >&2
  exit 1
fi
echo "Building with $(grep -E '^API_BASE_URL=' .env)"

flutter build web --release --dart-define-from-file=.env

rm -rf .vercel/output
mkdir -p .vercel/output
cp -R build/web .vercel/output/static
cat > .vercel/output/config.json <<'EOF'
{
  "version": 3,
  "routes": [
    {
      "src": "/(.*)",
      "headers": {
        "X-Content-Type-Options": "nosniff",
        "Referrer-Policy": "strict-origin-when-cross-origin",
        "X-Frame-Options": "DENY"
      },
      "continue": true
    },
    { "handle": "filesystem" },
    { "src": "/(.*)", "dest": "/index.html" }
  ]
}
EOF

# Run the latest CLI via npx: the deploy API rejects outdated CLI versions.
VERCEL=(npx --yes vercel@latest)
if [[ "${1:-}" == "preview" ]]; then
  "${VERCEL[@]}" deploy --prebuilt
else
  "${VERCEL[@]}" deploy --prebuilt --prod
fi
