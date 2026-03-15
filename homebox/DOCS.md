# Homebox Add-on Documentation

[Homebox](https://homebox.software) is an inventory and organization system built for the home user. It allows you to track and manage all of your belongings with a clean, intuitive web UI.

## Installation

1. Add this repository to your Home Assistant add-on store.
2. Install the **Homebox** add-on.
3. Configure the options (see below).
4. Start the add-on.
5. Open the Web UI and create your first account.

> **Tip:** After creating your first account, disable **Allow registration** in the add-on configuration to prevent other users from signing up.

## Configuration

### Option: `log_level`

Sets the verbosity of the Homebox logs. Options: `trace`, `debug`, `info`, `warn`, `error`, `fatal`, `panic`.

Default: `info`

### Option: `allow_registration`

When `true`, anyone who can reach the web UI can create a new account.

Set to `false` after creating your first account.

Default: `true`

### Option: `max_upload_size`

The maximum size (in MB) for file uploads such as item photos and attachments.

Default: `10`

### Option: `auto_increment_asset_id`

When `true`, Homebox auto-generates incremental asset IDs for new items. Disable this if you prefer to assign IDs manually.

Default: `true`

### Option: `barcode_token_barcodespider`

Optional API token for BarcodeSpider.com product lookup via barcode scanning.

Default: unset

### Option: `thumbnail_enabled`

Enable/disable thumbnail generation for uploaded images.

Default: Homebox default (`true`)

### Option: `thumbnail_width`

Thumbnail width in pixels.

Default: Homebox default (`500`)

### Option: `thumbnail_height`

Thumbnail height in pixels.

Default: Homebox default (`500`)

<details>
<summary>Email reminder configuration (optional)</summary>

These options enable Homebox reminder emails (for warranty and maintenance reminders):

- `mailer_host` — SMTP server hostname
- `mailer_port` — SMTP server port (defaults to `587` when unset/empty)
- `mailer_username` — SMTP username
- `mailer_password` — SMTP password
- `mailer_from` — sender email address

</details>

<details>
<summary>Single Sign-On (OIDC) configuration (optional)</summary>

These options enable OpenID Connect sign-in (for providers like Authentik or Keycloak):

- `oidc_enabled` — enable OIDC authentication
- `oidc_issuer_url` — OIDC issuer URL
- `oidc_client_id` — OIDC client ID
- `oidc_client_secret` — OIDC client secret
- `oidc_scope` — requested scopes (default in Homebox: `openid profile email`)
- `oidc_allowed_groups` — comma-separated allowed groups
- `oidc_auto_redirect` — redirect directly to provider
- `oidc_button_text` — login button text
- `oidc_verify_email` — require verified email claim
- `oidc_group_claim` — claim name for groups
- `oidc_email_claim` — claim name for email
- `oidc_name_claim` — claim name for display name
- `oidc_state_expiry` — state validity duration
- `oidc_request_timeout` — provider request timeout
- `allow_local_login` — allow username/password login while OIDC is enabled
- `hostname` — override hostname used in OIDC callback URLs

</details>

## Data Storage

All Homebox data (SQLite database, uploaded images and attachments) is stored in the add-on's persistent `/data` directory. This directory is included in Home Assistant backups automatically.

The database file is located at `/data/homebox.db`.

## Port

Homebox listens on port `7745` by default. You can change the external port mapping in the add-on **Network** configuration tab.

## Support

- [Homebox documentation](https://homebox.software/en/)
- [Homebox GitHub](https://github.com/sysadminsmedia/homebox)
- [Add-on GitHub](https://github.com/Crafter-Y/homebox-addon)
