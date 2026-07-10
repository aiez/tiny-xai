# vim: ts=2 sw=2 sts=2 et :
# knobs only; shared targets live in $(KONFIG)/Makefile
ROOT   := $(dir $(lastword $(MAKEFILE_LIST)))
KONFIG ?= $(ROOT)../konfig

APP   := tiny-xai
MAIN  := tiny-xai.lisp
EXT   := lisp
LANG  := clisp        # a2ps has clisp.ssh, no 'lisp.ssh'
TOOLS := sbcl:run-lisp
PKG   := sbcl gawk figlet neovim tmux

$(KONFIG)/Makefile:
	@test -f $@ || { echo "missing konfig: git clone https://github.com/aiez/konfig $(KONFIG)"; exit 1; }
include $(KONFIG)/Makefile

# ---- repo-specific lanes (after the include) ----------------
DATA ?= ../optimiz

tests: ## unit tests, sbcl only
	@sbcl --script tiny-xai.lisp --all

study: ## the four studies, default file, sbcl
	@sbcl --script tiny-xai.lisp --study

holdouts: ## 20-holdout mean per $(DATA) csv, 10-way parallel
	@ls $(DATA)/*.csv | (gshuf 2>/dev/null || sort -R) | \
	 xargs -P 10 -I{} sbcl --script tiny-xai.lisp \
	   --file {} --holdouts 2>/dev/null

deltas: ## rq2: active-vs-random win gap (0 = same), sorted
	@ls $(DATA)/*.csv | \
	 xargs -P 10 -I{} sbcl --script tiny-xai.lisp \
	   --file {} --delta 2>/dev/null | sort -n

budgets: ## rq1: budget 50-vs-20 win gap (0 = same), sorted
	@ls $(DATA)/*.csv | \
	 xargs -P 10 -I{} sbcl --script tiny-xai.lisp \
	   --file {} --budgets 2>/dev/null | sort -n

define _doc
	@mkdir -p docs
	@awk -f etc/doc.awk $< > docs/$(basename $(notdir $@)).scm
	@pycco -d docs docs/$(basename $(notdir $@)).scm >/dev/null
	@rm -f docs/$(basename $(notdir $@)).scm
	@grep -q '^p { text-align: right; }' docs/pycco.css || \
	  echo 'p { text-align: right; }' >> docs/pycco.css
	@python3 -c "import sys; p=sys.argv[1]; \
	  h=open('etc/header.txt').read(); s=open(p).read(); \
	  open(p,'w').write(s.replace('<h1', h+'<h1', 1))" $@
endef

doc: docs/tiny-xai.html docs/dtlz.html ## pycco api docs

docs/tiny-xai.html: src/tiny-xai.lisp etc/doc.awk etc/header.txt
	$(_doc)

docs/dtlz.html: dtlz.lisp etc/doc.awk etc/header.txt
	$(_doc)
