# vim: ts=2 sw=2 sts=2 et :
# standalone; help/doctor/push adapted from aiez/konfig
SHELL := /bin/bash
.DEFAULT_GOAL := help

DATA ?= ../optimiz # csv corpus (git clone github.com/aiez/optimiz)

help: ## show this help
	@cat banner.txt 2>/dev/null || true
	@printf "\nUsage:\n  make <target> [VAR=val ...]\n\ntargets:\n"
	@grep -hE '^[a-zA-Z][a-zA-Z0-9_ /.-]*:.*## ' $(MAKEFILE_LIST) | sort | \
	  awk -F':.*## ' '{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'
	@printf "\ndefaults:\n"
	@grep -hE '^[A-Z]+ \?=' $(MAKEFILE_LIST) | \
	  awk -F' \\?= |# ' '{printf "  \033[36m%s\033[0m = %-12s %s\n", $$1, $$2, $$3}'
	@echo " "

doctor: ## check required tools
	@for e in sbcl:tests clisp:portability awk:doc figlet:banners \
	          pycco:doc python3:doc xargs:lanes; do \
	   c=$${e%%:*}; use=$${e##*:}; \
	   if command -v $$c >/dev/null; then \
	     printf "  \033[32mok\033[0m %-8s used by: %s\n" "$$c" "$$use"; \
	   else \
	     printf "  \033[31mXX\033[0m %-8s missing: %s\n" "$$c" "$$use"; fi; done
	@printf "\nmacOS: brew install sbcl clisp figlet; pip install pycco\n"

push: ## add+commit+push+status; msg from cli (make push my note) else prompts
	@git add -A
	@m="$(filter-out $@,$(MAKECMDGOALS))"; \
	  [ -z "$$m" ] && { printf "commit msg (empty=save): "; read m </dev/tty; }; \
	  git commit -m "$${m:-save}" || true
	@git push
	@git status
%:            # swallow the message words so make won't error
	@:

# ---- repo lanes ---------------------------------------------

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
