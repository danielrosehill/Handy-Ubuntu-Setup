# Press-A-Button Voice Typing on Ubuntu (KDE Plasma / Wayland)

A guide to setting up one-press voice typing on Ubuntu 25.10 with KDE Plasma on Wayland using [Handy](https://github.com/pokey/handy) (a local speech-to-text tool) combined with a USB macro button or foot pedal and [Input Remapper](https://github.com/sezanzeb/input-remapper).

The end result: press a physical button, speak, and your words appear as typed text wherever your cursor is.

## Why This Guide Exists

Handy works well out of the box on X11, but getting it running smoothly on **KDE Plasma + Wayland** required a few non-obvious workarounds:

- The **overlay had to be disabled** — with it enabled, typed output wouldn't reach the active window.
- **ydotool had to be manually selected** as the typing tool — the default input method doesn't work on Wayland.
- **F13 would have been the ideal trigger key** (unlikely to conflict with anything), but Handy currently only supports a limited set of shortcut keys. `Pause` was used as a workaround, with Input Remapper translating the USB button press into `KEY_PAUSE`.

If you're on X11, you may not need all of these steps. But if you're on Wayland (which is the default on modern Ubuntu + KDE), this guide should save you some troubleshooting.

## Overview

The setup has three parts:

1. **Hardware** - A USB macro key, macro pad, or foot pedal that registers as a HID device
2. **Input Remapper** - Maps the button press to a keyboard shortcut (`Pause`, since Handy doesn't yet support keys like F13)
3. **Handy** - Listens for that shortcut and toggles voice transcription, typing the result directly into the active window via ydotool

## Hardware

Any programmable USB HID device will work. Options include:

- **Single USB macro button** - The simplest option. A single large button that sends one keycode. Works well with Handy's toggle-to-transcribe shortcut. Available cheaply on Amazon and AliExpress.
- **USB foot pedal** (1-3 keys) - Hands-free operation, great if you're typing and dictating simultaneously.
- **USB macro pad** (3+ buttons) - The most flexible option. With multiple buttons you can assign separate shortcuts for start, stop, and push-to-talk rather than relying on a single toggle. This gives you more control over the transcription workflow.

The device just needs to show up as a HID input device on Linux. No special drivers required.

See `configs/hardware/` for examples of devices that work.

## Setup

### 1. Install Handy

Install Handy from its repository or package. It runs as a background app with a system tray icon.

### 2. Configure Handy

#### General Settings

- **Transcribe Shortcut**: Set to `Pause` (or any key you prefer). This is the shortcut that will trigger transcription.
- **Microphone**: Select your preferred mic.
- **Audio Feedback**: Enable for an audible cue when transcription starts/stops.

See: `configs/handy/image copy.png`

#### Models

Choose a transcription model. **Parakeet V3** offers a good balance of accuracy and speed with multi-language support. Other options include Moonshine Base (fast, English only), Whisper variants (various sizes), and Canary models.

See: `configs/handy/image.png`, `configs/handy/image copy 2.png` through `image copy 4.png`

#### Advanced Settings

Key settings for a smooth experience:

| Setting | Recommended Value | Why |
|---|---|---|
| **Start Hidden** | On | Runs quietly in the background |
| **Launch on Startup** | On | Always available |
| **Show Tray Icon** | On | Easy access to settings |
| **Overlay Position** | None | **Required on Wayland** — with overlay enabled, typed output doesn't reach the active window |
| **Unload Model** | Never | Keeps the model in RAM for instant response |
| **Paste Method** | Direct | Types directly into the active window |
| **Typing Tool** | ydotool | **Required on Wayland** — the default typing method does not work under Wayland; must be set manually |
| **Clipboard Handling** | Don't Modify Clipboard | Avoids overwriting your clipboard contents |
| **History Limit** | 1 entry | Saves disk space |
| **Auto-Delete Recordings** | Keep latest 1 | Privacy-friendly |

See: `configs/handy/image copy 5.png` through `image copy 10.png`

### 3. Install Input Remapper

```bash
sudo apt install input-remapper
```

### 4. Configure Input Remapper

1. Open Input Remapper
2. Find your USB device in the **Devices** tab (it will show up by its HID identifier, e.g., `HID 5131:2019`)
3. Go to the **Presets** tab and create a new preset (e.g., "USB Voice Typing Trigger")
4. In the **Editor** tab:
   - Record the input from your button (click **Record**, then press the button)
   - Set the output type to **Key or Macro**
   - Set the target to **keyboard**
   - Map it to `KEY_PAUSE` (or whatever you set as Handy's transcribe shortcut)
   - **Note**: Ideally you'd use `F13` or another rarely-used key, but Handy currently only supports a limited set of shortcut keys. `Pause` is a good choice since it's rarely used by other applications.
5. Enable **Autoload** so the mapping persists across reboots
6. Click **Apply**

See: `configs/input-remapper/`

### Single Button vs Multi-Button Devices

With a **single button**, you use Handy's toggle mode: press once to start transcribing, press again to stop. Simple and effective.

With a **macro pad (3+ buttons)**, you can assign separate shortcuts for:
- **Start** transcription
- **Stop** transcription
- **Push-to-talk** (hold to record, release to stop)

This gives finer control and avoids accidentally toggling into the wrong state.

## Result

Once configured, the workflow is:

1. Handy launches silently at boot and loads the transcription model into memory
2. Input Remapper loads at boot and maps your USB device
3. Place your cursor in any text field
4. Press your button and speak
5. Text appears where your cursor is

See `configs/handy/image copy 11.png` for an example of transcribed output in Handy's history view.

## Wayland Troubleshooting

If transcription runs but no text appears in your application:

1. **Disable the overlay** — set Overlay Position to `None` in Handy's Advanced settings
2. **Set Typing Tool to ydotool** — the default doesn't work on Wayland
3. **Ensure ydotool is installed and its daemon is running** — `sudo apt install ydotool` and check that `ydotoold` is active
4. **Set Paste Method to Direct** — clipboard-based paste methods can be unreliable under Wayland

## System Requirements

- Ubuntu 25.10 (or similar) with KDE Plasma on Wayland
- A USB HID macro button, macro pad, or foot pedal
- Enough RAM to keep a transcription model loaded (varies by model size)

## Software Used

- **[Handy](https://github.com/pokey/handy)** - Local speech-to-text with direct typing output
- **[Input Remapper](https://github.com/sezanzeb/input-remapper)** - GUI tool for remapping input devices on Linux
- **ydotool** - Wayland-compatible virtual keyboard tool (used by Handy for typing output)
