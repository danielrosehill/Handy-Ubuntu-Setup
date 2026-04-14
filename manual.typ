#set document(
  title: "Press-A-Button Voice Typing on Ubuntu",
  author: "Daniel Rosehill",
  date: datetime(year: 2026, month: 4, day: 14),
)

#set page(
  paper: "a4",
  margin: (x: 2cm, y: 2.5cm),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(size: 9pt, fill: luma(120))
      Press-A-Button Voice Typing on Ubuntu
      #h(1fr)
      KDE Plasma / Wayland
    ]
  },
  footer: context {
    set text(size: 9pt, fill: luma(120))
    h(1fr)
    counter(page).display()
    h(1fr)
  },
)

#set text(font: "Liberation Sans", size: 11pt)
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.1")

#show heading.where(level: 1): it => {
  set text(size: 16pt, weight: "bold")
  v(0.5em)
  it
  v(0.3em)
}

#show heading.where(level: 2): it => {
  set text(size: 13pt, weight: "bold")
  v(0.4em)
  it
  v(0.2em)
}

#show heading.where(level: 3): it => {
  set text(size: 11pt, weight: "bold")
  v(0.3em)
  it
  v(0.1em)
}

#show raw.where(block: true): it => {
  set text(size: 9.5pt)
  block(
    fill: luma(245),
    inset: 10pt,
    radius: 4pt,
    width: 100%,
    it,
  )
}

// ── Title Page ──

#v(4cm)

#align(center)[
  #text(size: 28pt, weight: "bold")[Press-A-Button\ Voice Typing on Ubuntu]

  #v(1cm)

  #text(size: 14pt, fill: luma(80))[KDE Plasma / Wayland Setup Guide]

  #v(2cm)

  #text(size: 12pt)[
    Using *Handy* + *Input Remapper* + a USB macro button \
    for hands-free local speech-to-text
  ]

  #v(3cm)

  #text(size: 10pt, fill: luma(100))[
    Daniel Rosehill \
    Updated April 2026
  ]
]

#pagebreak()

// ── Table of Contents ──

#outline(indent: 1.5em, depth: 3)

#pagebreak()

// ── Content ──

= Introduction

This guide covers setting up one-press voice typing on Ubuntu 25.10 with KDE Plasma on Wayland using three components:

- *Handy* --- a local speech-to-text tool
- *Input Remapper* --- a GUI tool for remapping input devices on Linux
- A USB macro button, foot pedal, or macro pad

The end result: press a physical button, speak, and your words appear as typed text wherever your cursor is.

== Why This Guide Exists

Handy works well out of the box on X11, but getting it running smoothly on *KDE Plasma + Wayland* required several non-obvious workarounds:

+ The *overlay had to be disabled* --- with it enabled, typed output wouldn't reach the active window.
+ *ydotool had to be manually selected* as the typing tool --- the default input method doesn't work on Wayland.
+ *The trigger-key story is messier than you'd expect.* My personal preference --- and what I'd still recommend as the ideal --- is *F13*: not physically present on almost any keyboard, so emitting it from a USB macro button is guaranteed conflict-free. But as of the last validation date, Handy's shortcut library refuses to register it (`Unknown scancode for key: F13`), and bare single keys like `Pause` on KDE Wayland can silently fail to fire through the XDG GlobalShortcuts portal. The *second-best validated workaround* is `Ctrl+Alt+Space` --- a modifier combo tauri accepts and KDE doesn't claim.
+ *Do not switch `keyboard_implementation` to `handy_keys`* (the evdev backend). On this setup it grabs keystrokes and re-injects them through ydotool, causing a runaway loop that floods every focused window with garbage text. Stay on the default `tauri` implementation.

If you're on X11, you may not need all of these steps. On Wayland (the default on modern Ubuntu + KDE), this guide should save you significant troubleshooting.

== Validated Working Configuration (2026-04-14)

The exact setup confirmed working end-to-end --- button press $arrow.r$ recording $arrow.r$ transcription $arrow.r$ text at the cursor --- on Ubuntu 25.10, KDE Plasma 6, Wayland:

#figure(
  table(
    columns: (1fr, 1.5fr),
    align: (left, left),
    stroke: 0.5pt + luma(180),
    inset: 8pt,
    table.header(
      [*Setting*], [*Value*],
    ),
    [Handy `transcribe` binding], [`ctrl+alt+space`],
    [Handy `keyboard_implementation`], [`tauri`],
    [Handy `paste_method`], [`direct`],
    [Handy `typing_tool`], [`ydotool`],
    [Handy `clipboard_handling`], [`copy_to_clipboard`],
    [Handy `overlay_position`], [`none`],
    [Handy `push_to_talk`], [`false`],
    [Handy `selected_model`], [`parakeet-tdt-0.6b-v3`],
    [Input Remapper output], [`Control_L + Alt_L + space`],
    [ydotool daemon socket], [`/tmp/.ydotool_socket`],
  ),
  caption: [Validated working configuration],
)

Handy's settings file lives at `~/.local/share/com.pais.handy/settings_store.json`.

== Architecture Overview

#figure(
  table(
    columns: (1fr, 2fr),
    align: (center, left),
    stroke: 0.5pt + luma(180),
    inset: 8pt,
    table.header(
      [*Component*], [*Role*],
    ),
    [USB HID Device], [Physical trigger --- button, foot pedal, or macro pad],
    [Input Remapper], [Maps device button press to `Control_L + Alt_L + space`],
    [Handy], [Listens for `Ctrl+Alt+Space`, records audio, transcribes, and types the result via ydotool],
    [ydotool], [Wayland-compatible virtual keyboard for typing output into the active window],
  ),
  caption: [System components and their roles],
)

#pagebreak()

= Hardware

Any programmable USB HID device will work. The device just needs to show up as a HID input device on Linux --- no special drivers required.

== Single USB Macro Button

The simplest option. A single large button that sends one keycode. Works well with Handy's toggle-to-transcribe shortcut. Available cheaply on Amazon and AliExpress.

#figure(
  image("configs/hardware/usb-macro-button-amazon.png", width: 40%),
  caption: [USB macro button available on Amazon],
)

#figure(
  image("configs/hardware/aliexpress-usb-macro-buttons.png", width: 70%),
  caption: [USB macro button listings on AliExpress],
)

== USB Foot Pedal

Hands-free operation with 1--3 keys. Great if you're typing and dictating simultaneously.

#figure(
  image("configs/hardware/usb-foot-pedals-google-search.png", width: 70%),
  caption: [USB foot pedals --- various models available],
)

#figure(
  image("configs/hardware/aliexpress-usb-foot-pedals.png", width: 70%),
  caption: [USB foot pedal listings on AliExpress],
)

== USB Macro Pad

The most flexible option. With multiple buttons you can assign separate shortcuts for start, stop, and push-to-talk rather than relying on a single toggle.

#figure(
  image("configs/hardware/aliexpress-usb-macro-pads.png", width: 70%),
  caption: [USB macro pads on AliExpress --- multi-button options],
)

#pagebreak()

= Installing Handy

Install Handy from its GitHub repository or package. It runs as a background app with a system tray icon.

Repository: `https://github.com/cjpais/Handy`

#pagebreak()

= Configuring Handy

== General Settings

Configure the following in the *General* tab:

- *Transcribe Shortcut*: Set to `Ctrl+Alt+Space`. Modifier combos register reliably through the XDG portal; bare single keys (F13, Pause, media keys) are hit-and-miss on KDE Wayland.
- *Microphone*: Select your preferred mic
- *Audio Feedback*: Enable for an audible cue when transcription starts/stops

#figure(
  image("configs/handy/general-settings-transcribe-shortcut.png", width: 70%),
  caption: [General settings screenshot (from earlier iteration, showing `Pause`). Use `Ctrl+Alt+Space` instead --- `Pause` can silently fail to register on KDE Wayland.],
)

== Choosing a Transcription Model

Select a model from the *Models* tab. *Parakeet V3* offers a good balance of accuracy and speed with multi-language support.

#figure(
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center),
    stroke: 0.5pt + luma(180),
    inset: 8pt,
    table.header(
      [*Model*], [*Speed*], [*Accuracy*], [*Languages*],
    ),
    [Parakeet V3 _(recommended)_], [Fast], [High], [Multi-language],
    [Moonshine Base], [Very fast], [Good], [English only],
    [Moonshine V2 Medium], [Fast], [High], [English only],
    [Whisper Small], [Fast], [Fair], [Multi-language],
    [Whisper Medium], [Medium], [Good], [Multi-language],
    [Whisper Large], [Slow], [High], [Multi-language],
    [Whisper Turbo], [Fast], [Good], [Multi-language],
    [SenseVoice], [Very fast], [Good], [CJK + English],
    [Canary 180M Flash], [Very fast], [Good], [Multi-language],
    [Canary 1B v2], [Medium], [High], [25 languages],
  ),
  caption: [Available transcription models],
)

#figure(
  image("configs/handy/models-parakeet-v3-selected.png", width: 50%),
  caption: [Parakeet V3 selected as the active model],
)

#figure(
  image("configs/handy/models-list-whisper-sensevoice.png", width: 50%),
  caption: [Additional models --- Whisper variants and SenseVoice],
)

#figure(
  image("configs/handy/models-list-moonshine-canary.png", width: 50%),
  caption: [More models --- Moonshine V2, Canary, Whisper Turbo],
)

#pagebreak()

== Advanced Settings

These settings are critical for Wayland compatibility.

#figure(
  table(
    columns: (1.2fr, 1fr, 2fr),
    align: (left, center, left),
    stroke: 0.5pt + luma(180),
    inset: 8pt,
    table.header(
      [*Setting*], [*Value*], [*Reason*],
    ),
    [Start Hidden], [On], [Runs quietly in the background],
    [Launch on Startup], [On], [Always available],
    [Show Tray Icon], [On], [Easy access to settings],
    [Overlay Position], [*None*], [*Required on Wayland* --- overlay prevents typed output reaching the active window],
    [Unload Model], [*Never*], [Keeps the model in RAM for instant response],
    [Paste Method], [*Direct*], [Types directly into the active window],
    [Typing Tool], [*ydotool*], [*Required on Wayland* --- the default typing method does not work],
    [Clipboard Handling], [Copy to Clipboard], [Transcription text also lands on the clipboard as a fallback; switch to "Don't Modify" if you'd rather preserve the clipboard],
    [History Limit], [1 entry], [Saves disk space],
    [Auto-Delete Recordings], [Keep latest 1], [Privacy-friendly],
  ),
  caption: [Recommended Advanced settings (bold = Wayland-critical)],
)

#v(0.5em)

#figure(
  image("configs/handy/advanced-settings-overview.png", width: 50%),
  caption: [Advanced settings overview --- Overlay Position set to None, Typing Tool set to ydotool],
)

#figure(
  image("configs/handy/advanced-overlay-position-dropdown.png", width: 50%),
  caption: [Overlay Position dropdown --- select None],
)

#figure(
  image("configs/handy/advanced-unload-model-dropdown.png", width: 70%),
  caption: [Unload Model dropdown --- set to Never],
)

#figure(
  image("configs/handy/advanced-paste-method-dropdown.png", width: 50%),
  caption: [Paste Method dropdown --- select Direct],
)

#figure(
  image("configs/handy/advanced-clipboard-handling.png", width: 70%),
  caption: [Clipboard Handling --- select Don't Modify Clipboard],
)

#figure(
  image("configs/handy/advanced-history-settings.png", width: 70%),
  caption: [History settings --- limit to 1 entry, keep latest 1 recording],
)

#pagebreak()

= Installing Input Remapper

Install via apt:

```bash
sudo apt install input-remapper
```

Input Remapper provides a GUI for remapping any input device on Linux. It runs as a system service and persists mappings across reboots.

#pagebreak()

= Configuring Input Remapper

== Step 1: Select Your Device

Open Input Remapper and find your USB device in the *Devices* tab. It will appear by its HID identifier (e.g., `HID 5131:2019`).

#figure(
  image("configs/input-remapper/devices-tab-hid-selected.png", width: 80%),
  caption: [Devices tab --- select your USB HID device],
)

== Step 2: Create a Preset

Go to the *Presets* tab and create a new preset (e.g., "USB Voice Typing Trigger").

#figure(
  image("configs/input-remapper/presets-tab-voice-trigger.png", width: 60%),
  caption: [Presets tab --- USB Voice Typing Trigger preset created],
)

== Step 3: Map the Button

In the *Editor* tab:

+ Click *Record* and press your USB button to capture the input
+ Set the output type to *Key or Macro*
+ Set the target to *keyboard*
+ In the Output field, enter exactly: `Control_L + Alt_L + space`
+ Enable *Autoload* so the mapping persists across reboots
+ Click *Apply*

#figure(
  image("configs/input-remapper/editor-tab-ctrl-alt-space-mapping.png", width: 70%),
  caption: [Editor tab --- button mapped to `Control_L + Alt_L + space` with Autoload enabled],
)

#block(
  fill: rgb("#fff3cd"),
  inset: 12pt,
  radius: 4pt,
  width: 100%,
)[
  *Why a combo, not a single key?* `KEY_F13` would be the ideal single key (absent from almost every physical keyboard, so zero conflicts), but Handy's shortcut library currently rejects it with `Unknown scancode for key: F13`. Single keys like `KEY_PAUSE` can also silently fail to fire on KDE Wayland because the XDG GlobalShortcuts portal doesn't route them. `Ctrl+Alt+Space` goes through cleanly and has been validated end-to-end. See the _Why F13 Doesn't Work_ appendix for the technical detail.
]

#pagebreak()

= Single Button vs Multi-Button Devices

== Single Button (Toggle Mode)

With a single button, you use Handy's toggle mode: press once to start transcribing, press again to stop. Simple and effective.

== Multi-Button Macro Pad

With a macro pad (3+ buttons), you can assign separate shortcuts for:

- *Start* transcription
- *Stop* transcription
- *Push-to-talk* (hold to record, release to stop)

This gives finer control and avoids accidentally toggling into the wrong state.

#pagebreak()

= The Complete Workflow

Once everything is configured, the workflow is seamless:

+ Handy launches silently at boot and loads the transcription model into memory
+ Input Remapper loads at boot and maps your USB device
+ Place your cursor in any text field
+ Press your button and speak
+ Text appears where your cursor is

#figure(
  image("configs/handy/history-transcription-example.png", width: 70%),
  caption: [Example transcription result in Handy's History view],
)

#pagebreak()

= Wayland Troubleshooting

If transcription runs but no text appears in your application, check the following:

#figure(
  table(
    columns: (0.3fr, 1fr, 2fr),
    align: (center, left, left),
    stroke: 0.5pt + luma(180),
    inset: 8pt,
    table.header(
      [\#], [*Check*], [*Action*],
    ),
    [1], [Overlay disabled], [Set Overlay Position to `None` in Advanced settings],
    [2], [Typing Tool], [Set to `ydotool` in Advanced settings],
    [3], [ydotool installed], [Run `sudo apt install ydotool` and verify `ydotoold` is active. Default socket is `/tmp/.ydotool_socket` --- if you've set `YDOTOOL_SOCKET` in your shell rc files, make sure it points at a socket that actually exists.],
    [4], [Paste Method], [Set to `Direct` in Advanced settings],
  ),
  caption: [Wayland troubleshooting checklist],
)

== Hotkey Doesn't Fire

If pressing the hotkey does nothing at all --- no Marimba sound, no log entry for the press:

- Check `~/.local/share/com.pais.handy/logs/handy.log` for `register_tauri_shortcut registration error`. `Unknown scancode for key: F13` means Handy's library doesn't know that key --- use a modifier combo instead.
- Avoid bare single keys like `Pause`, `ScrollLock`, `Insert`, or media keys on KDE Wayland. They may log as "registered" but never fire because the XDG portal doesn't route them. A `Ctrl+Alt+Space`-style combo is the reliable fix.
- *Do not flip `keyboard_implementation` to `handy_keys`.* On this setup it causes a keystroke injection loop that floods whatever window has focus.
- Sending `SIGUSR1` to the Handy process is _not_ a reliable substitute for the hotkey --- the signal is received but the handler does not reliably trigger a recording.

== Appendix: Why F13 Doesn't Work (and What Could Fix It)

This section is speculative analysis of Handy's source, not a confirmed diagnosis from the maintainer. It's here to help anyone who'd like to submit a fix upstream.

=== Root Cause

Handy's default `keyboard_implementation` is `tauri`, which wraps the Rust `global-hotkey` crate. On Linux, `global-hotkey` registers hotkeys via either X11's `XGrabKey` or the XDG `org.freedesktop.portal.GlobalShortcuts` portal (on Wayland). Both paths translate a named key like `F13` into an X11 keysym or a Linux evdev scancode before registration.

The error surfaced in Handy's log is:

```
Unable to register hotkey: Unknown scancode for key: F13
```

This comes from `global-hotkey`'s Linux keycode-mapping table. Historically that table has covered `F1`--`F12` but omitted `F13`--`F24`, even though the `Code` enum (which mirrors the W3C `KeyboardEvent.code` spec) _does_ define `F13` through `F24`. Result: parsing "F13" into the enum succeeds, but the enum $arrow.r$ scancode step returns `None`, and registration fails.

On KDE Wayland specifically, there's a second issue: the XDG GlobalShortcuts portal expects pre-registered actions keyed by an application identifier. Tauri/`global-hotkey` submits a synthetic binding on the fly, which KWin/xdg-desktop-portal-kde may "accept" for modifier combos but silently drop for bare single keys (`Pause`, media keys, etc.) depending on compositor version. That's why `Pause` "registers" in the log but the press never actually reaches Handy.

=== What Handy / global-hotkey Could Change

Two options, in order of effort:

+ *Extend the Linux scancode table in `global-hotkey` to include `F13`--`F24`.* This is the minimum fix: add the missing `Code::F13 => 183`, `F14 => 184`, ... `F24 => 194` entries (Linux `KEY_F13`--`KEY_F24` evdev constants). One file, a dozen lines. Contributors already mapped F1--F12, so the pattern is established.
+ *Wire Handy's `handy_keys` evdev backend correctly* so it can be used as a safe fallback for compositor-restricted keys. The backend already exists but, on this setup, it triggers a runaway keystroke loop --- likely because it reads from `/dev/input/event*` _including_ the ydotool-injected virtual keyboard, so every transcription character it types re-triggers the hotkey. Adding a "grab the physical device exclusively" option (`EVIOCGRAB`) or filtering out `uinput`-sourced events would prevent the loop and make `handy_keys` viable for keys the portal won't route.

=== Effort / Scope Assessment for a PR

*Option 1 --- Add F13--F24 to `global-hotkey` (upstream):*

#figure(
  table(
    columns: (1fr, 2fr),
    align: (left, left),
    stroke: 0.5pt + luma(180),
    inset: 8pt,
    [Repository], [`tauri-apps/global-hotkey`],
    [Scope], [Linux backend only --- `src/platform_impl/linux/...`],
    [Files touched], [1--2 (scancode map + a test)],
    [Lines changed], [$tilde$20--30],
    [Coding effort], [30--60 min],
    [Test effort], [1--2 h (X11 + Wayland, extended F-keys are hard to test without extra hardware; input-remapper or `wtype --key F13` can simulate)],
    [Review risk], [Low --- additive change, existing F1--F12 pattern to follow],
    [Merge effort], [Maintainer responsiveness is the main variable; crate is reasonably active],
  ),
  caption: [Effort assessment --- extending scancode map],
)

Once merged upstream, Handy picks it up by bumping its `global-hotkey` dependency in `Cargo.toml` --- a one-line change and a fresh build.

*Option 2 --- Fix `handy_keys` evdev feedback loop (Handy-side):*

#figure(
  table(
    columns: (1fr, 2fr),
    align: (left, left),
    stroke: 0.5pt + luma(180),
    inset: 8pt,
    [Repository], [`cjpais/Handy`],
    [Scope], [`src/shortcut/handy_keys.rs` (or equivalent)],
    [Files touched], [1--3],
    [Lines changed], [$tilde$50--150],
    [Coding effort], [2--4 h],
    [Test effort], [2--4 h --- need to verify on X11, Wayland, Gnome, KDE, and with various typing tools (`wtype`, `ydotool`, `kwtype`) to ensure no regressions],
    [Review risk], [Medium --- evdev handling has subtle platform quirks; filtering uinput events requires reading device `ID_INPUT_JOYSTICK`-style properties],
    [Merge effort], [Bigger change, more review rounds likely],
  ),
  caption: [Effort assessment --- `handy_keys` loop fix],
)

*Recommendation:* start with Option 1 upstream --- it's a small, well-scoped, additive change that unlocks F13--F24 for every Tauri app, not just Handy. If that lands, the workaround-combo in this guide becomes unnecessary for users who want a clean single-key trigger.

= GPU Acceleration (AMD)

This setup was tested on an *AMD Radeon RX 7800 XT* (Navi 32, 12 GB VRAM) with ROCm. Handy uses ONNX Runtime for inference and automatically detects the AMD GPU --- no manual configuration is needed.

The `ort_accelerator` setting defaults to `auto`, and the log confirms GPU selection:

```
Auto-selected GPU device 0 'AMD Radeon RX 7700 XT (RADV NAVI32)'
(Dedicated, 12288 MB VRAM)
```

== Inference Benchmarks

Benchmarks from Handy's debug log using *Parakeet V3 (INT8)* on the RX 7800 XT:

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 2.5fr),
    align: (center, center, center, left),
    stroke: 0.5pt + luma(180),
    inset: 8pt,
    table.header(
      [*Recording*], [*Inference*], [*RTF*], [*Transcribed Text*],
    ),
    [~4 sec], [574 ms], [0.14x], [_"Okay, we're mapping out to the pause shortcuts here."_],
    [~6 sec], [912 ms], [0.15x], [_"Let's see if we're able to determine sentence boundaries..."_],
    [~16 sec], [1,695 ms], [0.11x], [_"It takes a few steps, but being able to enter text seamlessly..."_],
    [~4 sec], [554 ms], [0.14x], [_"This text was written."_],
    [~24 sec], [1,603 ms], [0.07x], [_"This text was written with parakeet, and the objective..."_ (long paragraph)],
  ),
  caption: [Inference benchmarks --- Parakeet V3 (INT8) on AMD RX 7800 XT],
)

*Model load time*: ~1,060--1,870 ms (first load is slower).

A real-time factor (RTF) below 1.0 means inference is faster than real-time. Parakeet V3 on this GPU consistently achieves *0.07--0.15x RTF*, meaning transcription completes in roughly 1/10th the time of the recording.

== Viewing Your Own Benchmarks

Check Handy's log for transcription timing:

```bash
grep "Transcription completed" \
  ~/.local/share/com.pais.handy/logs/handy.log
```

#pagebreak()

= System Requirements

- Ubuntu 25.10 (or similar) with KDE Plasma on Wayland
- A USB HID macro button, macro pad, or foot pedal
- Sufficient RAM for the transcription model (varies by model size)
- *GPU (optional but recommended)*: AMD GPU with ROCm support for accelerated inference. Tested on RX 7800 XT. CPU-only inference also works but will be slower.

= Software References

#figure(
  table(
    columns: (1fr, 2fr),
    align: (left, left),
    stroke: 0.5pt + luma(180),
    inset: 8pt,
    table.header(
      [*Software*], [*Description & Link*],
    ),
    [Handy], [`https://github.com/cjpais/Handy` --- Local speech-to-text with direct typing output],
    [Input Remapper], [`https://github.com/sezanzeb/input-remapper` --- GUI tool for remapping input devices on Linux],
    [ydotool], [Wayland-compatible virtual keyboard tool (used by Handy for typing output)],
  ),
  caption: [Software used in this setup],
)
