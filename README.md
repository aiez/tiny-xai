# tiny-xai

[![tests](https://github.com/aiez/tiny-xai/actions/workflows/tests.yml/badge.svg)](https://github.com/aiez/tiny-xai/actions/workflows/tests.yml)

Explainable multi-objective reasoning. Uses active learning to find
good models (regression trees) using fewest labels.

# Overview

tiny-xai reads CSVs whose header names the column roles (leading
uppercase = numeric; trailing `+`/`-` = goal to maximize or
minimize; trailing `X` = ignore; `?` cells = missing). It
summarizes columns, learns row-to-row distances, samples the
data landscape with a tiny labelling budget, grows regression
trees over the labelled rows, and grades results by how much
of the gap to the best row a pick closes.

A Common Lisp port of [ezr2.py](https://github.com/aiez/ezr2)
written in a tiny-function style. See [REPORT.md](REPORT.md) for a study
over 129 datasets: how good, how fast, and whether random
labelling does just as well.

# Tutorial

Two ways to reason: from data (a CSV) or from a live model
(code that computes goals on demand).

## Data-based reasoning: auto93

`auto93.csv` holds 398 cars: inputs like cylinders, engine
volume and model year; goals minimize weight (`Lbs-`),
maximize acceleration (`Acc+`) and miles-per-gallon (`Mpg+`).
Grow and show a tree over the last goal (Mpg):

    git clone https://github.com/aiez/optimiz   # data sits beside this repo
    sbcl --script tiny-xai.lisp --tree

First column = rows at that node, second = their mean Mpg,
then the branch condition. Read root-to-leaf as a rule
(some rows elided):

```
  398    23.84
  227    28.94  Volume <= 183
  123    31.71  |  Volume <= 112
   61    34.59  |  |  Model > 77
   54    35.19  |  |  |  Volume <= 107
  ...
  171    17.08  Volume > 183
  101    15.05  |  Volume > 260
   78    13.21  |  |  Model <= 76
    6    10.00  |  |  |  Volume > 429
```

Small, late-model engines reach 35 mpg; big old ones sink
toward 10.

## Model-based reasoning: dtlz

No CSV. The DTLZ benchmarks compute goals from x on demand
via the `*label*` hook -- the same pattern plugs in your own
(expensive) simulator, build rig or focus group:

    sbcl --script src/dtlz.lisp        # dtlz2: N=6 x-vars, M=2 goals

With a budget of 100 labels the rig picks a good option,
explains which x-ranges matter, then checks the recipe on
unseen data (some rows elided):

```
model dtlz2   N=6 x-vars   M=2 goals
best option found (one instance):
  x   0.42  0.50  0.74  0.62  0.53  0.65
  f   0.867  0.671   (disty 0.385, win 83; 100=best 0=median)
why? which x-ranges reach good goals:
   47     0.59
    6     0.68  X2 <= 0.11119955
   41     0.57  X2 > 0.11119955
   37     0.56  |  X5 > 0.073844224
   28     0.54  |  |  X4 > 0.19043517
   25     0.53  |  |  |  X4 <= 0.6802673
does it generalize? best on unseen data:
  x   0.29  0.48  0.55  0.44  0.52  0.68
  f   0.928  0.463   (disty 0.394, win 82; 100=best 0=median)
```

## Does any of this work?

Across 129 datasets (active labelling, budget 50, 20
repeats): 100 = the pick equals the best row in the data,
0 = no better than the median row. The median dataset
closes 85% of that gap; no dataset scores below zero:

```
[  0, 10)    1%  *
[ 10, 20)    1%  *
[ 20, 30)    0%
[ 30, 40)    4%  **
[ 40, 50)    5%  ***
[ 50, 60)    5%  **
[ 60, 70)   16%  *******
[ 70, 80)   12%  *****
[ 80, 90)   18%  ********
[ 90,100]   40%  *****************
```

Full study (how good, how fast, active vs random):
[REPORT.md](REPORT.md).

# Documentation

Annotated source, prose beside code (rebuilt by `make doc`;
each page's 🏠 badge returns here):

- [tiny-xai](https://aiez.github.io/tiny-xai/docs/tiny-xai.html)
  - the engine: columns, distances, landscape sampling,
  trees, stats
- [dtlz](https://aiez.github.io/tiny-xai/docs/dtlz.html) -
  plug an external model into the `*label*` hook (DTLZ1-7
  demo)
- [REPORT.md](REPORT.md) -
  the RQ0-RQ2 study: how good, how fast, how simple

# Usage

    git clone https://github.com/aiez/tiny-xai
    git clone https://github.com/aiez/optimiz   # the data
    cd tiny-xai
    sbcl --script tiny-xai.lisp -h          # options, tests
    sbcl --script tiny-xai.lisp --all       # unit tests, ~0.1s
    sbcl --script tiny-xai.lisp --study     # the studies, ~1s
    make holdouts deltas budgets        # 129-dataset sweeps

Or via ASDF/Quicklisp:

    (asdf:load-system "tiny-xai")
    (asdf:test-system "tiny-xai")

# License

Copyright (c) 2026 Tim Menzies <timm@ieee.org>

Licensed under the MIT License.
