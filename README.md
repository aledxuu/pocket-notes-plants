# Pocket Notes — Contacts

CC 105 Laboratory Activity: **Pocket Notes** (Divine Word College of Legazpi).
A Flutter app that remembers **contacts** (name, phone number) after it is closed.

- Record type: **Contacts** (class number ends in 4)
- Table: `contacts` → `id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone_number TEXT`
- Packages: `sqflite`, `path`, `shared_preferences` (`SharedPreferencesAsync`)

## Requirements checklist (Part 2)

| # | Requirement | Where |
|---|---|---|
| 1 | Light/dark switch saved with `SharedPreferencesAsync`, restored at launch | `lib/services/theme_service.dart`, `lib/main.dart` |
| 2 | List loaded from the sqflite table at launch | `ContactsPage.initState` → `_loadContacts()` |
| 3 | Add, edit (tap a row), delete (trash icon) | `lib/pages/contacts_page.dart` |
| 4 | Database opened once, one instance reused | `DatabaseHelper.instance` + cached `_dbFuture` |
| 5 | Update/delete with `where` + `whereArgs` | `updateContact`, `deleteContact` in `database_helper.dart` |

## Project structure

```
lib/
  main.dart                    app root, theme loading, Experiment 1 switch
  models/contact.dart          Contact model (toMap / fromMap)
  database/database_helper.dart  singleton sqflite helper (CRUD)
  services/theme_service.dart  SharedPreferencesAsync theme storage
  pages/contacts_page.dart     the one screen + add/edit dialog
test/widget_test.dart          model unit tests
```

## Run it

First time only, generate the platform folders (android/, ios/, windows/ …).
`flutter create` skips files that already exist, so your `lib/` code is kept:

```bash
flutter create . --project-name pocket_notes_contacts --platforms android,ios
flutter pub get
flutter run
```

Force-kill = swipe the app away from the recent-apps screen, then reopen from the home screen.
Hot reload / hot restart / stopping from the IDE do not count.

## Part 4 experiments

- **Experiment 1 (wrong-theme flash):** in `lib/main.dart` set
  `kBreakStartupThemeExperiment = true`, rebuild, set dark, force-kill, cold start.
  The first frame is light for ~2 seconds, then flips to dark. Set it back to `false` afterwards.
- **Experiment 2 (what survives):** star a contact and turn on the **Favorites only** chip.
  Those are plain `State` variables (RAM only), so they reset after a force-kill,
  while the theme (SharedPreferences) and contacts (SQLite) survive.

## Database proof (capture #7)

Every time the list loads, the console prints the raw rows:

```
DB ROWS (contacts): [{id: 1, name: ..., phone_number: ...}, ...]
```

Or use Android Studio → App Inspection → Database Inspector → `pocket_notes_contacts.db`.
