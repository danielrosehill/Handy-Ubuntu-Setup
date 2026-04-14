# Press-A-Button Voice Typing on Ubuntu (KDE Plasma / Wayland)

![Handy voice typing in action — transcription result](configs/handy/history-transcription-example.png)

A guide to setting up one-press voice typing on Ubuntu 25.10 with KDE Plasma on Wayland using [Handy](https://github.com/cjpais/Handy) (a local speech-to-text tool) combined with a USB macro button or foot pedal and [Input Remapper](https://github.com/sezanzeb/input-remapper).

The end result: press a physical button, speak, and your words appear as typed text wherever your cursor is.

**[Download the full setup manual (PDF)](manual.pdf)**

## Why This Guide Exists

Handy works well out of the box on X11, but getting it running smoothly on **KDE Plasma + Wayland** required a few non-obvious workarounds:

- The **overlay had to be disabled** — with it enabled, typed output wouldn't reach the active window.
- **ydotool had to be manually selected** as the typing tool — the default input method doesn't work on Wayland.
- **A modifier combo had to be used as the trigger key.** Single keys like `F13` or `Pause` are unreliable here: Handy's shortcut library rejects `F13` outright (`Unknown scancode for key: F13`), and on KDE Wayland the XDG GlobalShortcuts portal can silently drop bare single-key bindings. **`Ctrl+Alt+Space`** registers reliably and has no KDE default conflict — Input Remapper emits that combo from the USB button press.
- **Do not switch `keyboard_implementation` to `handy_keys`** (the evdev backend). On this setup it grabs keystrokes and re-injects them through ydotool, causing a runaway loop that floods every focused window with garbage text. Stay on the default `tauri` implementation.

If you're on X11, you may not need all of these steps. But if you're on Wayland (which is the default on modern Ubuntu + KDE), this guide should save you some troubleshooting.

## Overview

The setup has three parts:

1. **Hardware** - A USB macro key, macro pad, or foot pedal that registers as a HID device
2. **Input Remapper** - Maps the button press to `Ctrl+Alt+Space` (a combo Handy's shortcut system accepts reliably on KDE Wayland)
3. **Handy** - Listens for that shortcut and toggles voice transcription, typing the result directly into the active window via ydotool

## Hardware

Any programmable USB HID device will work. Options include:

- **Single USB macro button** - The simplest option. A single large button that sends one keycode. Works well with Handy's toggle-to-transcribe shortcut. Available cheaply on Amazon and AliExpress.
- **USB foot pedal** (1-3 keys) - Hands-free operation, great if you're typing and dictating simultaneously.
- **USB macro pad** (3+ buttons) - The most flexible option. With multiple buttons you can assign separate shortcuts for start, stop, and push-to-talk rather than relying on a single toggle. This gives you more control over the transcription workflow.

The device just needs to show up as a HID input device on Linux. No special drivers required.

### Hardware Examples

![USB macro button on Amazon](configs/hardware/usb-macro-button-amazon.png)
*Single USB macro button — the simplest option*

![AliExpress USB macro button listings](configs/hardware/aliexpress-usb-macro-buttons.png)
*USB macro buttons available on AliExpress*

![USB foot pedals — Google search results](configs/hardware/usb-foot-pedals-google-search.png)
*USB foot pedals — hands-free voice typing*

![AliExpress USB foot pedal listings](configs/hardware/aliexpress-usb-foot-pedals.png)
*USB foot pedals on AliExpress*

![AliExpress USB macro pad listings](configs/hardware/aliexpress-usb-macro-pads.png)
*USB macro pads on AliExpress — multi-button option*

## Setup

### 1. Install Handy

Install Handy from its repository or package. It runs as a background app with a system tray icon.

### 2. Configure Handy

#### General Settings

- **Transcribe Shortcut**: Set to `Ctrl+Alt+Space`. Modifier combos register reliably through the XDG portal; bare single keys (F13, Pause, media keys) are hit-and-miss on KDE Wayland.
- **Microphone**: Select your preferred mic.
- **Audio Feedback**: Enable for an audible cue when transcription starts/stops.

![Handy General settings — Transcribe Shortcut set to Pause](configs/handy/general-settings-transcribe-shortcut.png)
*Screenshot from an earlier iteration showing `Pause`. Use `Ctrl+Alt+Space` instead — `Pause` can silently fail to register on KDE Wayland.*

#### Models

Choose a transcription model. **Parakeet V3** offers a good balance of accuracy and speed with multi-language support. Other options include Moonshine Base (fast, English only), Whisper variants (various sizes), and Canary models.

![Handy Models tab — available models list](configs/handy/models-list-top.png)
*Available transcription models (Parakeet V3, Moonshine Base, Parakeet V2)*

![Handy Models tab — Parakeet V3 selected as active model](configs/handy/models-parakeet-v3-selected.png)
*Parakeet V3 selected as the active model*

![Handy Models tab — Whisper and SenseVoice models](configs/handy/models-list-whisper-sensevoice.png)
*Additional models: Whisper Small/Medium/Large, SenseVoice*

![Handy Models tab — Moonshine V2, Canary, and Whisper Turbo](configs/handy/models-list-moonshine-canary.png)
*More models: Moonshine V2 Medium, Canary 180M Flash, Whisper Turbo, Canary 1B v2*

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
| **Clipboard Handling** | Copy to Clipboard | Transcription text also lands on the clipboard as a fallback. Switch to "Don't Modify" if preserving clipboard is more important to you. |
| **History Limit** | 1 entry | Saves disk space |
| **Auto-Delete Recordings** | Keep latest 1 | Privacy-friendly |

![Handy Advanced settings — overview with overlay set to None](configs/handy/advanced-settings-overview.png)
*Advanced settings overview — note Overlay Position set to None and Typing Tool set to ydotool*

![Handy Advanced settings — Overlay Position dropdown expanded](configs/handy/advanced-overlay-position-dropdown.png)
*Overlay Position dropdown — select None for Wayland compatibility*

![Handy Advanced settings — Unload Model dropdown expanded](configs/handy/advanced-unload-model-dropdown.png)
*Unload Model dropdown — set to Never for instant response*

![Handy Advanced settings — Paste Method dropdown expanded](configs/handy/advanced-paste-method-dropdown.png)
*Paste Method dropdown — select Direct for Wayland*

![Handy Advanced settings — Clipboard Handling set to Don't Modify](configs/handy/advanced-clipboard-handling.png)
*Clipboard Handling — select Don't Modify Clipboard*

![Handy Advanced settings — History and auto-delete settings](configs/handy/advanced-history-settings.png)
*History settings — limit to 1 entry, keep latest 1 recording*

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
   - In the Output field, enter the combo that matches Handy's transcribe shortcut. For `Ctrl+Alt+Space`, use Input Remapper's combo syntax: `Control_L + Alt_L + space` (or equivalently the macro `modify(Control_L, modify(Alt_L, key(space)))`).
   - **Why a combo, not a single key**: `KEY_F13` is rejected by Handy's shortcut library, and single keys like `KEY_PAUSE` can silently fail to fire on KDE Wayland. A `Ctrl+Alt+Space` combo goes through the XDG portal cleanly.
5. Enable **Autoload** so the mapping persists across reboots
6. Click **Apply**

![Input Remapper Devices tab — HID 5131:2019 USB device selected](configs/input-remapper/devices-tab-hid-selected.png)
*Devices tab — select your USB HID device (e.g., HID 5131:2019)*

![Input Remapper Presets tab — USB Voice Typing Trigger preset](configs/input-remapper/presets-tab-voice-trigger.png)
*Presets tab — create a preset named "USB Voice Typing Trigger"*

![Input Remapper Editor tab — button mapped to KEY_PAUSE](configs/input-remapper/editor-tab-key-pause-mapping.png)
*Earlier iteration showing `KEY_PAUSE`. Current recommendation: map the button to `Control_L + Alt_L + space` instead.*

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

![Handy History tab — example transcription output](configs/handy/history-transcription-example.png)
*Example transcription result shown in Handy's History view*

## Wayland Troubleshooting

If transcription runs but no text appears in your application:

1. **Disable the overlay** — set Overlay Position to `None` in Handy's Advanced settings
2. **Set Typing Tool to ydotool** — the default doesn't work on Wayland
3. **Ensure ydotool is installed and its daemon is running** — `sudo apt install ydotool` and check that `ydotoold` is active. The daemon's default socket is `/tmp/.ydotool_socket`; if you've set `YDOTOOL_SOCKET` in your shell rc files, make sure it points at a socket that actually exists.
4. **Set Paste Method to Direct** — clipboard-based paste methods can be unreliable under Wayland

If pressing the hotkey does nothing at all (no Marimba sound, no log entry for the press):

- Check `~/.local/share/com.pais.handy/logs/handy.log` for `register_tauri_shortcut registration error`. `Unknown scancode for key: F13` means Handy's library doesn't know that key — use a modifier combo instead.
- Avoid bare single keys like `Pause`, `ScrollLock`, `Insert`, or media keys on KDE Wayland. They may log as "registered" but never fire because the XDG portal doesn't route them. A `Ctrl+Alt+Space`-style combo is the reliable fix.
- **Do not flip `keyboard_implementation` to `handy_keys`.** On this setup it causes a keystroke injection loop that floods whatever window has focus.
- `SIGUSR1` to the Handy process is not a reliable substitute for the hotkey — the signal is received but the handler does not reliably trigger a recording.

## GPU Acceleration (AMD)

This setup was tested on an **AMD Radeon RX 7800 XT** (Navi 32, 12 GB VRAM) with ROCm. Handy uses ONNX Runtime for inference and automatically detects the AMD GPU:

```
Auto-selected GPU device 0 'AMD Radeon RX 7700 XT (RADV NAVI32)' (Dedicated, 12288 MB VRAM)
```

No manual GPU configuration is needed — Handy's `ort_accelerator` defaults to `auto`.

### Inference Benchmarks

Benchmarks from Handy's debug log using **Parakeet V3 (INT8)** on the RX 7800 XT:

| Recording Duration | Inference Time | Real-Time Factor | Transcribed Text |
|---|---|---|---|
| ~4 sec | 574 ms | 0.14x | "Okay, we're mapping out to the pause shortcuts here." |
| ~6 sec | 912 ms | 0.15x | "Let's see if we're able to determine sentence boundaries..." |
| ~16 sec | 1,695 ms | 0.11x | "It takes a few steps, but being able to enter text seamlessly..." |
| ~4 sec | 554 ms | 0.14x | "This text was written." |
| ~24 sec | 1,603 ms | 0.07x | "This text was written with parakeet, and the objective..." (long paragraph) |

**Model load time**: ~1,060–1,870 ms (first load is slower).

A real-time factor (RTF) below 1.0 means inference is faster than real-time. Parakeet V3 on this GPU consistently achieves **0.07–0.15x RTF**, meaning transcription completes in roughly 1/10th the time of the recording.

To view your own benchmarks, check Handy's log:

```bash
grep "Transcription completed" ~/.local/share/com.pais.handy/logs/handy.log
```

## System Requirements

- Ubuntu 25.10 (or similar) with KDE Plasma on Wayland
- A USB HID macro button, macro pad, or foot pedal
- Enough RAM to keep a transcription model loaded (varies by model size)
- **GPU (optional but recommended)**: AMD GPU with ROCm support for accelerated inference. Tested on RX 7800 XT. CPU-only inference also works but will be slower.

## Software Used

- **[Handy](https://github.com/cjpais/Handy)** - Local speech-to-text with direct typing output
- **[Input Remapper](https://github.com/sezanzeb/input-remapper)** - GUI tool for remapping input devices on Linux
- **ydotool** - Wayland-compatible virtual keyboard tool (used by Handy for typing output)
