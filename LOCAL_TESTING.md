# Local Testing

Two ways to test locally — Docker required, VS Code devcontainer not required.

## Full Home Assistant Environment

```bash
./scripts/ha-test.sh
```

First run pulls ~2 GB and boots in ~3-5 min. Subsequent starts reuse the container.

| URL | When available |
|-----|----------------|
| http://localhost:7123 | After Supervisor is ready |
| http://localhost:7745 | After addon is installed & started |

**First-time setup:** Open http://localhost:7123, create an account, then **Settings → Add-ons → Add-on Store → Local add-ons → Homebox → Install → Start**.

**Development workflow:**

```
Edit code  →  ./scripts/ha-test.sh shell  →  ha apps rebuild local_homebox
```

The script automatically handles the `image:` field in `config.yaml` (comments it out on start, restores on stop) so the Supervisor builds from your local Dockerfile instead of pulling from the registry.

**Other commands:** `stop`, `shell`, `logs`, `destroy` — run `./scripts/ha-test.sh` without arguments for help.

---

## Standalone Docker (quick smoke test)

```bash
./scripts/local-test.sh
```

Builds and runs just Homebox at http://localhost:7745 (~10 s). No HA, no ingress, no Supervisor. Edit `scripts/options.json` to change addon options.

```bash
./scripts/local-test.sh 8080         # custom port
./scripts/local-test.sh --build-only # build only
rm -rf test-data/                    # reset data
```

Expect harmless `Could not resolve host: supervisor` errors in the logs — the S6 base services try to contact the Supervisor API which isn't available.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "Can't rebuild a image based add-on" | The script should handle this automatically. If not, comment out the `image:` line in `homebox/config.yaml`, then inside the container: `docker restart hassio_supervisor`, uninstall and reinstall. |
| Supervisor shows old version | Inside the container: `docker restart hassio_supervisor` |
| Addon not in Add-on Store | Add-on Store → ⋮ → Check for updates |
| "permission denied" on scripts (Windows) | `git rm --cached -r . && git reset --hard` (re-normalizes line endings) |
| Port already in use | Edit port constants in `scripts/ha-test.sh`, or `./scripts/local-test.sh 8080` |
| Standalone container exits | Check `scripts/options.json` is valid JSON, then `rm -rf test-data/` and retry |
