# Windows installer validation

Temporary native validation for an authorized protected Windows installer. This repository contains only test automation and sanitized evidence; no application source, credentials, raw channel binding or private build diagnostics.

The workflow uses Windows PowerShell 5.1 on Windows Server 2022 and 2025. Downloaded candidate and baseline installers are checked against SHA-256 values in `candidate.json` before execution. Channel: `XINBAO-AI`.

Installer `--updated` mode and normal interactive installation are tested separately. This does not redirect the application's production update feed or claim end-to-end update discovery/download coverage.
