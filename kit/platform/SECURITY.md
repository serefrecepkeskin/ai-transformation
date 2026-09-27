# Security — platform

<!-- PLACEHOLDER — the workspace bootstrap fills this from code, CI and the repos' own docs; every claim is
     checked against the code, what cannot be checked is marked TODO(confirm). Only what holds across repos
     belongs here; a single repo's details go to that repo's docs/engineering/. -->

## Services and trust boundaries

TODO(confirm) — who calls whom, over what, with which credential.

## Shared secrets

TODO(confirm) — which secret must be identical in which services; how it is rotated.

## Tokens and sessions

TODO(confirm)

## Pre-production checklist

TODO(confirm) — at least: config files holding secrets are mode 600 and owned by the service user; no
default/demo credentials; debug/docs endpoints off; proxy trust matches the reverse proxy.

## Open risks (platform-wide)

TODO(confirm) — each with the reason it is accepted.
