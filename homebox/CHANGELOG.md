# Changelog

## 0.23.5

- Dependency updates


## 0.23.4

- Dependency updates


## 0.23.3

- Fixed data loss risk on restart by removing startup cleanup that deleted SQLite `.db-wal` files
- Switched to Homebox official database variable `HBOX_DATABASE_SQLITE_PATH`
- Added startup log line that prints the active SQLite database file path
- Database path is `/data/homebox.db`

## 0.23.1

- Initial release based on Homebox v0.23.1
- Multi-arch support (amd64, aarch64)
- Fixed `/tmp` permission denied crash at startup
- Proper S6 overlay v3 service structure
- Configurable options: log level, allow registration, max upload size
- Data stored in persistent `/data/homebox/` directory
