# -*- coding: utf-8 -*-
"""Create some figures for paper."""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

import glob
import os

if not os.path.exists("./figures"):
    os.mkdir('figures')


def _get_csv(f, it):
    foo = pd.read_csv(f, skiprows=20)
    foo['TIME'] += 20 * it
    return foo

plt.rc('text', usetex=True)
plt.rc('font', family='serif')
for files in [glob.glob('data/*.csv')[i * 3:(i + 1) * 3] for i in range(3)]:
    df = pd.concat([_get_csv(f, i) for i, f in enumerate(sorted(files))])
    df.set_index('TIME', inplace=True)
    nonnanvals = df.CH2.dropna().tolist()
    df['CH2'] = np.nan
    df.iloc[:len(nonnanvals), 0] = nonnanvals
    df.dropna(inplace=True)
    # df = df.iloc[:20000, :]
    relevant_points = df[df.diff() >= 6]
    selected_points = relevant_points.dropna().iloc[::2].reset_index()
    title = np.unique(map(lambda s: " ".join(s.split("/")[-1].replace(".csv", "").split("_")[1:-1]).title().replace("Mit", "mit").replace("Und", "und").replace("Ohne", "ohne"), files))
    assert len(title) == 1
    title = title[0]
    fig, [ax, ax2] = plt.subplots(2, 1, sharex=True, figsize=(10, 2))
    # fig.suptitle(title, fontsize=14)
    df.plot(ax=ax)
    relevant_points.plot(ax=ax, style=['x'])
    ax.legend_.set_visible(False)
    selected_points['TIME'].diff().plot(ax=ax2, style='x')
    ax.set_title(
        "{} ({}): {}".format(
            "following diffs found in time",
            "drop them occuring less than $3\%$",
            ", ".join([
                "{}s: ${}3\%$".format(k, v * 100)
                for k, v
                in selected_points['TIME'].diff().round(2).dropna().value_counts(
                    normalize=True).round(3).iteritems()
                if v > 0.03
            ])
        ))
    # fig.tight_layout(h_pad=0.1, rect=[0, 0, 1, .92])  # this if suptitle
    fig.tight_layout(h_pad=0.1, rect=[0, 0, 1, 1])
    fig.savefig('figures/' + "".join(title.split()) + '.pdf')
    plt.close(fig)
