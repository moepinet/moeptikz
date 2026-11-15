## Makefile
## Copyright 2015-2026 Stephan M. Guenther
#
# This work may be distributed and/or modified under the
# conditions of the LaTeX Project Public License, either version 1.3c
# of this license or (at your option) any later version.
# The latest version of this license is in
#   https://www.latex-project.org/lppl.txt
# and version 1.3c or later is part of all distributions of LaTeX
# version 2008 or later.
#
# This work has the LPPL maintenance status `maintained'.
#
# The Current Maintainer of this work is Stephan M. Guenther.
#
# This work consists of the files moeptikz.sty, moeptikz-doc.tex,
# README.md and Makefile and the derived file moeptikz-doc.pdf.
#
# The complete work and its issue tracker are available at
#   https://github.com/moepinet/moeptikz
#
# make            builds moeptikz-doc.pdf (auxiliary files in build/)
# make fresh      rebuilds it from scratch
# make clean      removes the auxiliary files, make cleanall also the PDF

MAKEFLAGS += -r -R

.SILENT :
.NOTPARALLEL :
.PHONY  : all clean cleanall fresh

DOCUMENT := moeptikz-doc
SRC := $(DOCUMENT).tex
SRC += $(wildcard *.sty)
DEPS := $(SRC) Makefile
TARGET   := moeptikz-doc

PDFLATEX ?= pdflatex
GREP ?= grep
MV ?= mv

PDFLATEX_FLAGS	:= -interaction=batchmode -file-line-error
GREP_FLAGS += -a -E -B 1 -A 2

# terminal colors
ifneq ($(COLORTERM),false)
  NOCOLOR := "\033[0m"
  RED := "\033[1;31m"
  GREEN := "\033[1;32m"
  MAGENTA := "\033[1;35m"
  BOLD := "\033[1m"
else
  NOCOLOR := ""
  RED := ""
  GREEN := ""
  MAGENTA := ""
  BOLD := ""
endif

# messaging functions
msgtarget = printf $(GREEN)"%s"$(MAGENTA)" %s"$(NOCOLOR)"\n" "$(1)" "$(2)"
msgcompile = printf $(BOLD)"%-25s"$(NOCOLOR)" %s\n" "[$(1)]" "$(2)"
msgfail = printf "%-25s "$(RED)"%s"$(NOCOLOR)"\n" "" "FAILED! Continuing ..."

define run-typeset
  $(call msgcompile,$(PDFLATEX),$(1)); \
  $(PDFLATEX) $(PDFLATEX_FLAGS) $(TARGET_PDFLATEX_FLAGS) $(1) </dev/null 1>/dev/null 2>&1 || \
    $(call msgfail)
endef

define run-draft-typeset
  $(call msgcompile,$(PDFLATEX),$(1)); \
  $(PDFLATEX) $(PDFLATEX_FLAGS) $(TARGET_PDFLATEX_FLAGS) -draftmode $(1) </dev/null 1>/dev/null 2>&1 || \
    $(call msgfail)
endef

define extract-log
  $(call msgtarget,Extracting log file for target,$(1)); \
  $(GREP) $(GREP_FLAGS) -e ":[[:digit:]]+: |Warning|Error|Underfull|Overfull|!" \
    $(1).log || :
endef

.PHONY: $(DOCUMENT)
$(DOCUMENT): $(TARGET).pdf

$(TARGET).pdf: TARGET_PDFLATEX_FLAGS = -output-directory=build/$(DOCUMENT)
$(TARGET).pdf: $(DEPS)
	mkdir -p build/$(DOCUMENT)
	$(call run-draft-typeset,$<)
	$(call run-typeset,$<)
	$(call extract-log,build/$(DOCUMENT)/$(DOCUMENT))
	$(MV) build/$(DOCUMENT)/$(DOCUMENT).pdf "$@"

all: $(DOCUMENT)

clean:
	rm -rfv build
	rm -fv $(DOCUMENT).aux $(DOCUMENT).log

cleanall: clean
	rm -fv $(TARGET).pdf

fresh: cleanall
	$(MAKE) --no-print-directory all
