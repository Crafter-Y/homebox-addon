# Changelog

## 0.24.2.10

- Dependency updates


## 0.24.2.9

- Fix add-on option schema optional markers so upgrades no longer fail validation with missing `thumbnail_height?`

## 0.24.2.8

- Expose `auto_increment_asset_id` as a configurable add-on option
- Add optional mailer configuration fields (`mailer_host`, `mailer_port`, `mailer_username`, `mailer_password`, `mailer_from`) with mailer port fallback to `587`
- Add optional OIDC/SSO configuration fields (`oidc_*`, `allow_local_login`, `hostname`)
- Add optional barcode and thumbnail settings (`barcode_token_barcodespider`, `thumbnail_enabled`, `thumbnail_width`, `thumbnail_height`)
- Document all newly exposed options in `DOCS.md`

## 0.24.2.7

- Fix ingress rewrite for root-relative `/no-image.jpg` fallback image URL so it loads correctly behind Home Assistant ingress

## 0.24.2.6

- Rewrite additional root-relative ingress asset URLs so bundled icons, manifests, and placeholder images load through Home Assistant ingress
- Rewrite template-literal websocket API URLs and extend nginx upgrade timeouts so ingress websocket connections stay connected

## 0.24.2.5

- Fix ingress login by stripping cookie Domain attribute so browsers accept auth cookies
- Remove sub_filter for /_nuxt/ that caused double-prefixed asset URLs
- Allow file uploads up to 100 MB through ingress proxy

## 0.24.2.4

- Fix nginx crash on HAOS: run nginx as root to avoid permission errors with user/group switching

## 0.24.2.3

- Fixed ingress on generic x86_64

## 0.24.2.2

- Fix nginx ingress startup on HAOS by moving runtime temp/log state to writable paths

## 0.24.2.1

- Added HA ingress support for sidebar access (nginx reverse proxy)

## 0.24.2.0

- Updated Homebox from 0.24.1 to 0.24.2


## 0.24.1.0

- Updated Homebox from 0.24.0 to 0.24.1


## 0.24.0.1

- Use pre-built GHCR images for amd64 and aarch64 installs.

## 0.24.0.0

- Updated Homebox from 0.23.1 to 0.24.0
- Updated devcontainer from 2-addons to 3-addons


## 0.23.1.0

- Initial release based on Homebox v0.23.1
