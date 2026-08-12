<div align="center">

# caffeine

**Keep your computer awake — for as long as the terminal stays open.**

[![Platform: macOS](https://img.shields.io/badge/macOS-supported-000?logo=apple&logoColor=white)](#macos)
[![Platform: Windows](https://img.shields.io/badge/Windows-supported-0078D6?logo=windows&logoColor=white)](#windows)
[![Platform: Linux](https://img.shields.io/badge/Linux-supported-FCC624?logo=linux&logoColor=black)](#linux)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](#license)

</div>

---

`caffeine` is a tiny CLI that stops your machine from going to sleep, dimming, or locking while it is running. Start it, leave the terminal window open, and your computer stays awake. Hit **Ctrl + C** and it goes back to normal.

```text
$ caffeine
caffeine  0h 0m 12s  [Ctrl+C] to stop.
```

## Table of contents

- [Why](#why)
- [How it works](#how-it-works)
- [Install](#install)
  - [macOS](#macos)
  - [Linux](#linux)
  - [Windows](#windows)
- [Usage](#usage)
- [Notes and caveats](#notes-and-caveats)
- [License](#license)

## Why

Sometimes you need the machine to stay on — a long download, a render, a build, a presentation, a remote session — but you do not want to fiddle with system power settings and then remember to change them back. `caffeine` is a one‑command on/off switch that scopes itself to the lifetime of a terminal.

## How it works

`caffeine` does not fight the OS. It asks each platform, using its own supported API, to hold the machine awake:

| Platform | Mechanism |
|---|---|
| macOS   | `caffeinate -dimsu` (subprocess). Prevents display sleep, idle sleep, system sleep on AC, and marks user active. |
| Linux   | `systemd-inhibit --what=idle:sleep:handle-lid-switch`, blocking on `sleep infinity`. |
| Windows | `SetThreadExecutionState(ES_CONTINUOUS \| ES_SYSTEM_REQUIRED \| ES_DISPLAY_REQUIRED)` via P/Invoke. |

When you press **Ctrl + C** (or close the terminal), the inhibitor child process exits or the execution‑state flag is cleared, and the OS returns to its normal power policy.

> **The terminal must stay open.** That is the whole design. Close the window, lose the lock. There is no daemon, no background service, no login item.

## Install

Clone the repo once, then follow the section for your OS. Nothing needs to be built.

```bash
git clone https://github.com/<you>/caffeine.git
cd caffeine
```

> Replace `<you>` with the account you host it under.

### macOS

Either the shell script (no dependencies) or the Python script — they behave identically.

```bash
chmod +x caffeine.sh
sudo install -m 0755 caffeine.sh /usr/local/bin/caffeine
```

Python variant:

```bash
chmod +x caffeine
sudo install -m 0755 caffeine /usr/local/bin/caffeine
```

Requires macOS 10.9+ (ships with `caffeinate`).

### Linux

Works on any distro with `systemd` (Ubuntu, Debian, Fedora, Arch, openSUSE, Pop!_OS, Mint, Manjaro, etc.).

```bash
chmod +x caffeine.sh
sudo install -m 0755 caffeine.sh /usr/local/bin/caffeine
```

Python variant (works on non‑systemd distros too, best‑effort):

```bash
chmod +x caffeine
sudo install -m 0755 caffeine /usr/local/bin/caffeine
```

If you don't have root, drop it in `~/.local/bin` instead and make sure that's on your `PATH`.

> On distros without `systemd-inhibit` (Alpine, some minimal setups) install `systemd` or use the Python variant, which falls back to an activity heartbeat.

### Windows

PowerShell 5.1+ (built into Windows 10 and 11). After cloning, run it directly:

```powershell
powershell -ExecutionPolicy Bypass -File .\caffeine.ps1
```

If you would rather type just `caffeine`, drop this one‑liner in your PowerShell profile (`$PROFILE`):

```powershell
Set-Alias caffeine "C:\path\to\caffeine\caffeine.ps1"
```

## Usage

```text
caffeine
```

That is the whole interface. While it runs, the elapsed time updates every second:

```text
caffeine  0h 4m 27s  [Ctrl+C] to stop.
```

Press **Ctrl + C** to stop it. The OS returns to whatever power settings it had before you started.

## Notes and caveats

- **Closing the terminal stops it.** By design. If you need something persistent, use your OS's power settings.
- **Laptop lid.** On macOS and Windows, closing the lid still sleeps the machine (the OS does not let user apps override that). On Linux with `systemd-inhibit`, `handle-lid-switch` is included in the inhibitor, so closing the lid will *not* suspend while caffeine runs.
- **Battery.** Keeping the display and CPU awake uses more power. Prefer AC when you can.
- **Root/admin not required** on any platform.

## License

MIT.
