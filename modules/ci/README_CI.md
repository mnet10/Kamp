# CI Workflow

This branch adds a GitHub Actions workflow to run Flutter analyze and tests on push and pull_request events.

Files:
- .github/workflows/flutter_ci.yml

Notes:
- The workflow caches Pub packages and runs on pushes to main and any feature branches, and on PRs targeting main.
- Hardware-dependent tests (camera, flashlight) should be mocked or excluded from CI.
