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

## Data Storage

All Homebox data (SQLite database, uploaded images and attachments) is stored in the add-on's persistent `/data` directory. This directory is included in Home Assistant backups automatically.

The database file is located at `/data/homebox.db`.

## Port

Homebox listens on port `7745` by default. You can change the external port mapping in the add-on **Network** configuration tab.

## Support

- [Homebox documentation](https://homebox.software/en/)
- [Homebox GitHub](https://github.com/sysadminsmedia/homebox)
- [Add-on GitHub](https://github.com/Crafter-Y/homebox-addon)
