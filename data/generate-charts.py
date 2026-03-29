#!/usr/bin/env python3
"""Generate benchmark charts from transcription-benchmarks.json"""

import json
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')

with open('data/transcription-benchmarks.json') as f:
    data = json.load(f)

results = data['results']

# Sort by inference time
results_by_speed = sorted(results, key=lambda r: r['inference_time_ms'])
models = [r['model'] for r in results_by_speed]
times = [r['inference_time_ms'] for r in results_by_speed]
error_counts = [len(r['errors']) for r in results_by_speed]

# Color by error count
colors = ['#2ecc71' if e == 0 else '#f39c12' if e <= 2 else '#e74c3c' for e in error_counts]

fig, axes = plt.subplots(2, 1, figsize=(12, 10))
fig.suptitle('Handy STT Model Benchmarks — VAD & Hallucination Test\n'
             'AMD Radeon RX 7800 XT (Navi 32, 12 GB VRAM) · Handy 0.8.1',
             fontsize=14, fontweight='bold')

# Chart 1: Inference time
ax1 = axes[0]
bars = ax1.barh(models, times, color=colors, edgecolor='#333', linewidth=0.5)
ax1.set_xlabel('Inference Time (ms)')
ax1.set_title('Inference Speed (lower is better)')
ax1.invert_yaxis()
for bar, t in zip(bars, times):
    ax1.text(bar.get_width() + 50, bar.get_y() + bar.get_height()/2,
             f'{t} ms', va='center', fontsize=9)
ax1.set_xlim(0, max(times) * 1.25)

# Chart 2: Error count
results_by_errors = sorted(results, key=lambda r: len(r['errors']))
models_e = [r['model'] for r in results_by_errors]
errors_e = [len(r['errors']) for r in results_by_errors]
colors_e = ['#2ecc71' if e == 0 else '#f39c12' if e <= 2 else '#e74c3c' for e in errors_e]

ax2 = axes[1]
bars2 = ax2.barh(models_e, errors_e, color=colors_e, edgecolor='#333', linewidth=0.5)
ax2.set_xlabel('Number of Errors')
ax2.set_title('Transcription Accuracy (lower is better)')
ax2.invert_yaxis()
ax2.set_xlim(0, max(errors_e) + 1)
for bar, e in zip(bars2, errors_e):
    ax2.text(bar.get_width() + 0.1, bar.get_y() + bar.get_height()/2,
             str(e), va='center', fontsize=9)

# Legend
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor='#2ecc71', label='Perfect (0 errors)'),
                   Patch(facecolor='#f39c12', label='Minor (1-2 errors)'),
                   Patch(facecolor='#e74c3c', label='Significant (3+ errors)')]
ax2.legend(handles=legend_elements, loc='lower right')

plt.tight_layout()
plt.savefig('data/benchmark-charts.png', dpi=150, bbox_inches='tight')
print('Saved data/benchmark-charts.png')

# Chart 3: Speed vs accuracy scatter
fig2, ax3 = plt.subplots(figsize=(10, 7))
fig2.suptitle('Speed vs Accuracy Tradeoff\n'
              'AMD Radeon RX 7800 XT · Handy 0.8.1',
              fontsize=14, fontweight='bold')

for r in results:
    e = len(r['errors'])
    color = '#2ecc71' if e == 0 else '#f39c12' if e <= 2 else '#e74c3c'
    ax3.scatter(r['inference_time_ms'], e, s=120, c=color, edgecolors='#333',
                linewidth=0.5, zorder=5)
    ax3.annotate(r['model'], (r['inference_time_ms'], e),
                 textcoords='offset points', xytext=(8, 5), fontsize=8)

ax3.set_xlabel('Inference Time (ms)')
ax3.set_ylabel('Number of Errors')
ax3.set_title('Ideal models are in the bottom-left corner')
ax3.legend(handles=legend_elements, loc='upper right')
ax3.set_ylim(-0.5, max(len(r['errors']) for r in results) + 1)

plt.tight_layout()
plt.savefig('data/speed-vs-accuracy.png', dpi=150, bbox_inches='tight')
print('Saved data/speed-vs-accuracy.png')
