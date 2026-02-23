# Regain

A minimal macOS menu bar app that prevents your Mac from sleeping.

## Features

- **Sleep Prevention** — IOPMAssertion-based system & display sleep prevention (auto-enabled on launch)
- **Launch at Login** — Automatically start on login
- **Aggressive Mode** — Applies pmset settings to prevent sleep on lid close and battery

## Requirements

- macOS 13.0+
- Xcode
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## Build & Run

```bash
brew install xcodegen
make run
```

## Aggressive Mode Settings

```bash
pmset -a sleep 0 disksleep 0 displaysleep 0
pmset -a hibernatemode 0 powernap 0
pmset -a standby 0 autopoweroff 0
pmset -a autorestart 1
```

Turning it off restores defaults via `pmset restoredefaults`.
