# TaskNote

A simple, local-first task and note manager that lives in your macOS menu bar. No cloud, no accounts — just plain markdown files on disk.

## Features

- **Menu bar app** — always one click away, stays out of your way
- **Tasks** — add, edit, complete, and delete tasks
- **Notes** — quick capture for thoughts and snippets
- **Today view** — flag tasks for today and focus on what matters
- **Plain markdown** — `tasks.md` and `notes.md` files you can edit anywhere
- **File watching** — external edits sync instantly
- **Global shortcut** — open TaskNote from any app
- **Lightweight** — native Swift, no Electron, minimal resources

## Build

```bash
./build.sh
```

The app bundle is output to `build/TaskNote.app`. To create a distributable zip:

```bash
./build.sh --zip
```

## Keyboard Shortcuts

| Action | Shortcut |
|---|---|
| Open popover | Global hotkey (configured in Settings) |
| Add task/note | Type in input bar, press **Enter** |
| Edit task | **Double-click** task text, **Enter** to save, **Escape** to cancel |
| Edit note | **Double-click** note, **Cmd+Enter** to save, **Escape** to cancel |

## File Format

### tasks.md

Standard markdown checkboxes. Tasks flagged for today have a trailing `#today` tag:

```markdown
- [ ] Buy groceries #today
- [x] Call dentist
- [ ] Review PR
```

### notes.md

Date-headed sections with freeform content:

```markdown
## 2026-02-11 14:30

Meeting notes from standup

## 2026-02-10 09:15

Ideas for the new feature
```

## Data Location

By default, files are stored in `~/.tasknote/`. You can change the storage directory in Settings.
