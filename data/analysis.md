# Handy STT Model Benchmark Analysis

## Test Environment

| Component | Detail |
|---|---|
| **Application** | Handy 0.8.1 |
| **Inference runtime** | ONNX Runtime (ORT accelerator: auto) + Whisper.cpp (Whisper accelerator: auto) |
| **GPU** | AMD Radeon RX 7800 XT (Navi 32, 12,288 MB VRAM) |
| **CPU** | 12th Gen Intel Core i7-12700F |
| **OS** | Ubuntu 25.10 (Questing Quokka), kernel 6.17.0-19-generic |
| **GPU detection** | Auto-selected GPU device 0 'AMD Radeon RX 7700 XT (RADV NAVI32)' (Dedicated, 12288 MB VRAM) |
| **Date** | 2026-03-29 |

## Test Script

Two unrelated sentences separated by a 5-second silence, designed to test:

1. **Transcription accuracy** — word-level correctness, punctuation, capitalisation
2. **VAD (Voice Activity Detection)** — whether models handle a mid-recording silence cleanly
3. **Hallucination** — whether models invent words during the silent gap

> I had scrambled eggs and toast for breakfast this morning. The coffee was a bit too strong but I drank it anyway. **[5 second pause]** The capital of France is Paris. It sits on the River Seine and has a population of about two million people in the city itself.

## Results Summary

### Ranking by Overall Quality (accuracy + speed)

| Rank | Model | Inference (ms) | RTF | Errors | Hallucination |
|---:|---|---:|---:|---:|:---:|
| 1 | **Whisper Small** | 976 | 0.07x | 0 | No |
| 2 | **Parakeet V2** | 1,354 | 0.09x | 0 | No |
| 3 | **Moonshine Base** | 2,301 | 0.15x | 0 | No |
| 4 | **Canary 180M Flash** | 2,223 | 0.17x | 0 | No |
| 5 | **Parakeet V3 (INT8)** | 1,378 | 0.10x | 1 | No |
| 6 | **Whisper Turbo** | 1,112 | 0.09x | 2 | No |
| 7 | **Moonshine Small Streaming** | 4,140 | 0.33x | 1 | No |
| 8 | **Canary 1B v2** | 2,473 | 0.17x | 1 | No |
| 9 | **Whisper Medium** | 1,694 | 0.13x | 3 | No |
| 10 | **Whisper Large** | 2,780 | 0.22x | 3 | No |
| 11 | **Moonshine Tiny Streaming** | 3,414 | 0.25x | 2 | No |
| 12 | **Breeze ASR** | 2,626 | 0.20x | 3 | No |
| 13 | **SenseVoice (INT8)** | 145 | 0.01x | 3 | No |

### Perfect Transcriptions (0 errors)

Four models achieved a perfect transcription with no errors:

- **Whisper Small** — fastest of the perfect group (976 ms)
- **Parakeet V2** — second fastest (1,354 ms)
- **Canary 180M Flash** — correct capitalisation and spelled-out numbers (2,223 ms)
- **Moonshine Base** — accurate but slower (2,301 ms)

### VAD & Hallucination

All 13 models handled the 5-second silence without hallucinating. No model inserted filler words, repeated phrases, or invented bridging text during the pause. This is a strong result across the board.

### Common Error Patterns

| Error Type | Models Affected |
|---|---|
| "River Seine" → "river Seine" (capitalisation) | Parakeet V3, Whisper Turbo, Whisper Medium, Whisper Large, Moonshine Small Streaming, Moonshine Tiny Streaming, Breeze ASR |
| "two million" → "2 million" (numeral) | Whisper Turbo, Whisper Medium, Whisper Large, Canary 1B v2, SenseVoice |
| Missing/wrong commas | Whisper Medium, Whisper Large |
| Sentence boundaries lost (periods → commas) | SenseVoice, Breeze ASR |
| Significant mishearing | Moonshine Tiny ("drank it anyway" → "don't get any way"), SenseVoice ("Seine" → "sand") |
| Dropped words | Canary 1B v2 ("people in" dropped) |

### Speed Observations

- **SenseVoice (INT8)** is an outlier at 145 ms but sacrifices too much accuracy for general use.
- The **Whisper family** shows an inverse size-performance relationship on this GPU: Small (976 ms) outperforms Medium (1,694 ms) and Large (2,780 ms) on both speed and accuracy.
- **Moonshine Streaming models** are the slowest overall (3,414–4,140 ms), likely due to their streaming architecture processing overhead.
- All models achieve real-time factors well below 1.0x, meaning transcription is always faster than the recording duration.

## Recommendation

**Whisper Small** is the clear winner for this hardware setup — fastest inference, perfect accuracy, and no hallucinations. **Parakeet V2** is a strong second choice with similarly perfect output.

For users who care about proper noun capitalisation and spelled-out numbers, **Canary 180M Flash** is worth considering despite being slower, as it was the only model to correctly capitalise "River Seine" while also spelling out "two million".

## Charts

- [Inference speed and accuracy bar charts](benchmark-charts.png)
- [Speed vs accuracy scatter plot](speed-vs-accuracy.png)
