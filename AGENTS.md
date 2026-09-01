# Hodiy Repository Instructions

## Execution environment

- This Oracle server is `aarch64`. Flutter, Dart, Java, and the Android SDK are not installed and cannot be installed here because the required toolchain is x64-only.
- Write code in this repository, but never claim to run formatting, analysis, tests, or builds locally. Run all of those checks in GitHub Actions on `ubuntu-latest` (x64).
- For every change: implement it, commit it, push it, wait for CI to finish with `gh run watch`, and inspect the result. Do not pretend that local verification is available.
- Keep every task small and independent. Try at most three CI iterations for one task. If CI is still red after the third iteration, stop and report the state instead of retrying forever.
- A completion report needs a receipt: state the commit SHA and the URL of the green CI run. Saying only that the work is done is insufficient.

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
