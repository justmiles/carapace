## Environment

You're running in **Carapace**, an isolated container with GUI capabilities.

**Key features:**
- X11 display via Xpra (view at `localhost:7756`)
- Chromium browser: `chromium "<url>"`
- Nix packages: `nix-shell -p <package> --run "<command>"`
- Public files: `/workspace/public` → served on port 8080

**Set in the container:**

```bash
CARAPACE=1
```

**Agent/scripts can check:**

```bash
if [ -n "$CARAPACE" ]; then
  echo "Running in Carapace"
fi
```


See `skills/carapace/SKILL.md` for full documentation.


