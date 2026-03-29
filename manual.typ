#set document(
  title: "Press-A-Button Voice Typing on Ubuntu",
  author: "Daniel Rosehill",
  date: datetime(year: 2026, month: 3, day: 29),
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
    March 2026
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
+ *F13 would have been the ideal trigger key* (unlikely to conflict with anything), but Handy currently only supports a limited set of shortcut keys. `Pause` was used as a workaround.

If you're on X11, you may not need all of these steps. On Wayland (the default on modern Ubuntu + KDE), this guide should save you significant troubleshooting.

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
    [Input Remapper], [Maps device button press to `KEY_PAUSE` keyboard shortcut],
    [Handy], [Listens for shortcut, records audio, transcribes, and types the result via ydotool],
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

Repository: `https://github.com/pokey/handy`

#pagebreak()

= Configuring Handy

== General Settings

Configure the following in the *General* tab:

- *Transcribe Shortcut*: Set to `Pause` (or any key you prefer)
- *Microphone*: Select your preferred mic
- *Audio Feedback*: Enable for an audible cue when transcription starts/stops

#figure(
  image("configs/handy/general-settings-transcribe-shortcut.png", width: 70%),
  caption: [General settings --- Transcribe Shortcut set to Pause],
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
    [Clipboard Handling], [Don't Modify], [Avoids overwriting clipboard contents],
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
+ Map it to `KEY_PAUSE`
+ Enable *Autoload* so the mapping persists across reboots
+ Click *Apply*

#figure(
  image("configs/input-remapper/editor-tab-key-pause-mapping.png", width: 70%),
  caption: [Editor tab --- button mapped to KEY_PAUSE with Autoload enabled],
)

#block(
  fill: rgb("#fff3cd"),
  inset: 12pt,
  radius: 4pt,
  width: 100%,
)[
  *Note:* Ideally you'd use `F13` or another rarely-used key, but Handy currently only supports a limited set of shortcut keys. `Pause` is a good choice since it's rarely used by other applications.
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
    [3], [ydotool installed], [Run `sudo apt install ydotool` and verify `ydotoold` is active],
    [4], [Paste Method], [Set to `Direct` in Advanced settings],
  ),
  caption: [Wayland troubleshooting checklist],
)

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
    [Handy], [`https://github.com/pokey/handy` --- Local speech-to-text with direct typing output],
    [Input Remapper], [`https://github.com/sezanzeb/input-remapper` --- GUI tool for remapping input devices on Linux],
    [ydotool], [Wayland-compatible virtual keyboard tool (used by Handy for typing output)],
  ),
  caption: [Software used in this setup],
)
