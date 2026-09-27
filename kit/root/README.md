# root/

`workspace.conf` is the one list of this workspace — which AI tool the team uses and which repo gets which
profile. Everything else is derived from it: `install.sh` clones the repos it lists, `scripts/link-repo.sh --root`
writes `workspace.code-workspace` at the workspace root, `scripts/check-drift.sh` checks every repo in it.

```
tool=both                  # claude | copilot | both
repo api-service backend   # repo <folder name> <backend|frontend|skip>
repo web-app frontend
```

A repo marked `skip` stays in the workspace but gets no kit wiring (docs, infra, a repo another team owns).
