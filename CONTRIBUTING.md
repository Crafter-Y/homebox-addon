# Contributing

Contributions are welcome — whether that's code, bug reports, or ideas via issues and pull requests.

## Guidelines

- **Test your changes** before submitting if at all possible. Run the addon locally using the devcontainer.
- **AI-assisted contributions are fine**, but please review and clean up generated output before opening a PR. Low-effort slop will be asked to be revised.
- **Bump the version** in `homebox/config.yaml` if your change affects runtime behavior. Use the `<homebox_version>.<addon_patch>` scheme (e.g. `0.24.0.1`).
- **Prepend a changelog entry** in `homebox/CHANGELOG.md` describing what changed.

## Version format

```
<homebox_major>.<homebox_minor>.<homebox_patch>.<addon_patch>
```

The `<addon_patch>` starts at `0` for each new Homebox release and increments for every subsequent addon-only change.
