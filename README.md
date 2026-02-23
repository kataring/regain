# Regain

A minimal macOS menu bar app that prevents your Mac from sleeping.

## Download

[Releases](https://github.com/kataring/regain/releases) から最新の DMG をダウンロードできます。

> 未署名アプリのため、初回起動時にGatekeeperにブロックされます。以下のコマンドで quarantine 属性を除去してから起動してください。
>
> ```
> xattr -cr /Applications/Regain.app
> ```

## Features

- **Sleep Prevention** — IOPMAssertion-based system & display sleep prevention (auto-enabled on launch)
- **Launch at Login** — Automatically start on login

## Requirements

- macOS 13.0+
- Xcode
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## Build & Run

```bash
brew install xcodegen
make run
```
