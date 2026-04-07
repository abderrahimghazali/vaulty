# Vaulty

![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue.svg)
![License MIT](https://img.shields.io/badge/License-MIT-green.svg)

A native macOS menubar app that generates TOTP codes for any 2FA-enabled service. Replace reaching for your phone — all your authenticator codes live in the menubar, one click away.

## Features

- **Menubar native** — Lives in the macOS menubar as an NSPopover. No dock icon, no window clutter.
- **TOTP generation** — RFC 6238 compliant. HMAC-SHA1/SHA256/SHA512 via CryptoKit.
- **One-click copy** — Click any account to copy the current code to clipboard.
- **Countdown ring** — Visual timer shows remaining seconds. Pulses red when expiring.
- **QR code scanning** — Capture any `otpauth://` QR code visible on screen.
- **Keychain storage** — Secrets stored exclusively in macOS Keychain. Never written to disk in plain text.
- **Search** — Filter accounts by name or issuer.
- **Global shortcut** — `⌘⇧V` to toggle Vaulty from anywhere.

## Installation

**Requirements:** macOS 14.0+, Xcode 15.0+, [XcodeGen](https://github.com/yonaskolb/XcodeGen)

```bash
# Clone
git clone https://github.com/abderrahimghazali/vaulty.git
cd vaulty

# Generate Xcode project
xcodegen generate

# Open in Xcode
open Vaulty.xcodeproj
```

Build and run (`⌘R`). Vaulty appears in the menubar.

## Usage

| Action | How |
|--------|-----|
| Open/close | Click the menubar icon or press `⌘⇧V` |
| Copy code | Click an account row |
| Add account | Click `+` → enter manually or scan QR |
| Scan QR | Click "Scan QR from screen" (QR must be visible, popover hides first) |
| Delete account | Right-click an account → Delete |
| Search | Type in the search bar (appears with 3+ accounts) |

## Permissions

Vaulty requires **Screen Recording** permission for QR scanning. Go to **System Settings → Privacy & Security → Screen Recording** and enable Vaulty.

> **Tip:** If QR scanning fails after a rebuild, toggle the Screen Recording permission off and back on.

## Security

- Secrets are stored in the macOS Keychain via the Security framework.
- Only non-sensitive metadata (issuer, account name) is stored on disk.
- No network calls. No cloud sync. No telemetry.

## Tech Stack

| Component | Technology |
|-----------|-----------|
| UI | SwiftUI + NSPopover |
| TOTP | CryptoKit (HMAC-SHA1/256/512) |
| Storage | macOS Keychain (Security framework) |
| QR detection | Vision framework (VNDetectBarcodesRequest) |
| Screen capture | CGWindowListCreateImage |
| Project config | XcodeGen |

## License

MIT

## Author

[@abderrahimghazali](https://github.com/abderrahimghazali)
