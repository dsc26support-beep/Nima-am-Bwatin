# Nima-am-Bwatin

A bilingual (English / Kiribati) Android app for tracking medications, doctor
and clinic appointments, and blood sugar readings.

## Features

- **Medications** — track up to 20 medications with dosage and a flexible
  reminder schedule (times per day, specific times, every X hours, or
  specific weekdays). Reminders fire as local notifications, even after the
  phone restarts.
- **Appointments** — record doctor/clinic appointments and get a reminder
  notification ahead of time.
- **Blood sugar & dietary advice** — enter an RBS (random) or FBS (fasting)
  blood sugar reading in mmol/L or mg/dL, and see which band it falls into
  (normal / prediabetes / diabetes) along with general dietary advice. This
  is general guidance only, not a diagnosis.
- **English / Kiribati toggle** — switch the whole app's language from
  Settings.
- **Local-only data** — everything stays on your phone (no account, no
  backend). Export/import a JSON backup file from Settings before switching
  phones.

## Getting the app onto your phone

Every push to this repo builds a debug APK via GitHub Actions
(`.github/workflows/build-apk.yml`). Download it from the workflow run's
**Artifacts** section and install it on your Android device (you'll need to
allow "install unknown apps" for whichever app you use to open the file).

To build locally instead:

```
flutter pub get
flutter build apk --debug   # or --release, once you've set up your own signing key
```

## Translations

All English UI text lives in `assets/lang/en.json`. Kiribati translations go
in `assets/lang/gil.json`. `translation/kiribati_translation_sheet.md` is a
plain-language handoff sheet listing every string for a translator to fill
in; until it's translated, `gil.json` mirrors the English text as a
placeholder so the language toggle is fully wired end-to-end.

## Project structure

See `lib/` for the app source: `models/` (data types), `services/`
(notifications, database, localization, dietary advice, export/import),
`repositories/` (DB access), `providers/` (Riverpod state), and `screens/`
(UI, one folder per feature area).
