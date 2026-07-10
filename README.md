# tiny-xai

[![tests](https://github.com/aiez/tiny-xai/actions/workflows/tests.yml/badge.svg)](https://github.com/aiez/tiny-xai/actions/workflows/tests.yml)

Landscape analysis for XAI and optimization CSVs: how few
labels buy a good row?

# Overview

tiny-xai reads CSVs whose header names the column roles (leading
uppercase = numeric; trailing `+`/`-` = goal to maximize or
minimize; trailing `X` = ignore; `?` cells = missing). It
summarizes columns, learns row-to-row distances, samples the
data landscape with a tiny labelling budget, grows regression
trees over the labelled rows, and grades results by how much
of the gap to the best row a pick closes.

A Common Lisp port of [ezr2.py](https://github.com/aiez/ezr2)
written in a tiny-function style. See `REPORT.md` for a study
over 129 datasets: how good, how fast, and whether random
labelling does just as well.

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
