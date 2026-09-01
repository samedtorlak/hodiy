# Hodiy Repository Instructions

## Execution environment

- This Oracle server is `aarch64`. There is no Android SDK/Java here, so `flutter build apk`/`appbundle` still cannot run locally — that stays in GitHub Actions on `ubuntu-latest` (x64).
- **CORRECTION (2026-09-02): full Flutter DOES run locally, not just Dart.** Earlier guidance in this file claiming Flutter itself needs x64 was wrong — untested assumption, not a real limitation. Flutter's own tool bootstraps an ARM64 Dart SDK automatically (`bin/flutter` detects the host arch and downloads the matching Dart build from the current engine — this is unrelated to the x64-only prebuilt Flutter *SDK archive* Google publishes for download; a `git clone` of the Flutter repo self-bootstraps correctly on arm64). A full Flutter checkout (stable channel) is installed at `/home/ubuntu/.local/flutter` (on PATH, `flutter`/`dart` resolve there — the standalone Dart-only SDK that used to be at `/home/ubuntu/.local/dart-sdk` is superseded, this one is a superset).
- **Run `flutter analyze --fatal-infos` and `flutter test` locally before every commit, exactly as CI does.** This is not optional anymore — it catches almost everything CI catches (formatting, analyzer errors, unit/widget test failures) in seconds instead of a 1-3 minute CI round trip, and avoids pushing broken commits that trigger spurious GitHub failure notifications on the user's phone. Run `flutter pub get` first if `pubspec.yaml` changed. `dart format lib test` still works the same way (now via the same install).
- Write code in this repository AND verify it locally (`flutter analyze` + `flutter test`) before claiming a task is done or pushing. CI remains the final authority (it also builds the actual APK, which can't be checked locally), but a red CI run after this change means something slipped through local verification — treat that as a process failure to learn from, not just a bug to fix.
- **`flutter analyze` works under your `workspace-write` sandbox, but `flutter test` does not** (confirmed 2026-09-02: it fails with "Failed to create server socket (OS Error: Operation not permitted)" — the test runner needs a loopback socket for its VM service, and the sandbox blocks that). Always run `flutter analyze --fatal-infos` yourself and report its real result. For `flutter test`, run it anyway and report honestly if it hits this specific socket error (don't claim untested code passed) — the calling agent (Claude) will run the real `flutter test` outside the sandbox before committing.
- For every change: implement it, verify locally, commit it, push it, wait for CI to finish with `gh run watch` as final confirmation (including the APK build step, which only runs in CI).
- Keep every task small and independent. Try at most three CI iterations for one task. If CI is still red after the third iteration, stop and report the state instead of retrying forever.
- A completion report needs a receipt: state the commit SHA and the URL of the green CI run. Saying only that the work is done is insufficient.
- **NEVER reference `secrets.*` inside a job- or step-level `if:` condition for a secret that has not been created in this repo's Settings → Secrets yet.** This was bisected and confirmed (2026-09-01): it makes the ENTIRE workflow fail to start (0 jobs, "failure", wrong registered name) on every push, not just evaluate to false. Referencing the same secret inside an `env:` block is safe. If a step needs to run conditionally on a secret's presence, put the secret only in `env:` and do the emptiness check inside the shell script (`if [ -z "$SECRET_VAR" ]; then ... exit 0; fi`), never in YAML `if:`. See `.github/workflows/publish.yml`'s "Configure release signing" step for the working pattern.
- **`AppLocalizations.of(context)` is non-nullable — never write `AppLocalizations.of(context)!`.** `l10n.yaml` has `nullable-getter: false`, so the generated getter already returns a non-nullable `AppLocalizations`. A trailing `!` triggers the `unnecessary_non_null_assertion` lint, which `flutter analyze --fatal-infos` treats as fatal (confirmed 2026-09-01, caught by Fable review before commit).

## Product invariants

- The Android application ID root is `com.msela.hodiy`. It is permanent after the first release; do not change it arbitrarily.
- Version 1 includes prayer times, a qibla compass, a tasbih counter, the Hijri date, and prayer-time notifications.
- Do not add Quran, hadith, or dua text. Those are outside the v1 scope because of licensing risk, and the scope must not be expanded without an explicit decision.
- Do not add analytics or an account system.
- Location is processed only on-device and requested once with `ACCESS_COARSE_LOCATION`. Never add background location permission.
- Advertising through `google_mobile_ads` must be behind the `ADS_ENABLED` Dart define. Real AdMob IDs do not exist yet; use test IDs when IDs are not supplied through GitHub Secrets.
- Never write secrets such as keystore passwords or AdMob IDs to repository files or commits. Store them only in GitHub Secrets.

## Language and localization

- Code must be English, including variable, function, and class names, comments, docstrings, commit messages, and file names.
- User-visible text must be localized through ARB files for Uzbek (`uz`), Kazakh (`kk`), Kyrgyz (`ky`), Tajik (`tg`), and Russian (`ru`). English (`en`) is the template locale.

## Android permission notes

- Android 13 and newer require the `POST_NOTIFICATIONS` runtime permission.
- On Android 14 and newer, `SCHEDULE_EXACT_ALARM` is disabled by default. Do not use `USE_EXACT_ALARM`, which is restricted by Google Play; provide an inexact-alarm fallback.
- Never request background location permission.
- `flutter_local_notifications` requires core library desugaring and multidex.

## Planned source layout

Do not create these paths until the relevant implementation task requires them:

```text
lib/
  main.dart
  app.dart
  core/
    localization/
    theme/
    ads/
    storage/
    location/
    util/
  features/
    prayer_times/{domain,state,ui}/
    qibla/{domain,state,ui}/
    tasbih/{domain,state,ui}/
    hijri/{domain,state,ui}/
    notifications/{domain,state,ui}/
    settings/{domain,state,ui}/
  l10n/
    app_en.arb
    app_ru.arb
    app_uz.arb
    app_kk.arb
    app_ky.arb
    app_tg.arb
test/
  unit/
  widget/
tool/
  method_table.dart
```

The landing page and privacy policy live in the separate public repo
`samedtorlak/hodiy-site` (GitHub Pages does not work on private repos on
the free plan), not in this repo. Do not recreate a `docs/` folder here.
```
