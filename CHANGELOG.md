# Changelog

## 2.x

### Added
- Support for [PM2 process files]((http://pm2.keymetrics.io/docs/usage/application-declaration)). Specify the file to use with the `pm2_process_file` option.

### Changed
- Many `pm2:` commands now take an app name as an argument, e.g. `pm2 show myapp`.
- Restarting is now graceful and does not require knowledge of the existing app status.
- `pm2:restart` is now an alias for `pm2:start_or_graceful_reload`.
- `pm2:list` has been renamed to `pm2:show`.

### Removed (BC break)
- `pm2_app_command`, `pm2_app_name`, and `pm2_target_path` options.
