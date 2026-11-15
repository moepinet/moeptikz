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
# make clean      removes build/ (auxiliary files and the CTAN archive),
#                 make cleanall also the PDF
# make ctan       builds the archive for CTAN, build/moeptikz.tar.gz

MAKEFLAGS += -r -R

.SILENT :
.NOTPARALLEL :
.PHONY  : all clean cleanall fresh ctan

PACKAGE := moeptikz
DOCUMENT := moeptikz-doc
SRC := $(DOCUMENT).tex
SRC += $(wildcard *.sty)
DEPS := $(SRC) Makefile
TARGET   := moeptikz-doc
CTAN_ARCHIVE := build/$(PACKAGE).tar.gz

PDFLATEX ?= pdflatex
GREP ?= grep
MV ?= mv
GIT ?= git
TAR ?= tar

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
msgabort = printf "%-25s "$(RED)"%s"$(NOCOLOR)"\n" "" "FAILED! $(TARGET).pdf is not updated"
msgwarning = printf $(MAGENTA)"Warning: %s"$(NOCOLOR)"\n" "$(1)" >&2
msgerror = printf $(RED)"Error: %s"$(NOCOLOR)"\n" "$(1)" >&2

define run-typeset
  $(call msgcompile,$(PDFLATEX),$(1)); \
  $(PDFLATEX) $(PDFLATEX_FLAGS) $(TARGET_PDFLATEX_FLAGS) $(1) </dev/null 1>/dev/null 2>&1 || \
    { $(call msgabort); false; }
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
	$(call run-typeset,$<) || { $(call extract-log,build/$(DOCUMENT)/$(DOCUMENT)); exit 1; }
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

# The archive for CTAN holds the files of the commit HEAD below moeptikz/,
# without those marked export-ignore in .gitattributes; uncommitted changes
# are not part of it.  moeptikz-doc.pdf must be committed after the last
# change of its sources.
ctan:
	rm -f $(CTAN_ARCHIVE)
	if [ "`$(GIT) rev-parse --show-toplevel 2>/dev/null`" != "`pwd -P`" ]; then \
	  $(call msgerror,make ctan needs the git repository of $(PACKAGE)); \
	  exit 1; \
	fi
	if [ -n "`$(GIT) status --porcelain`" ]; then \
	  $(call msgwarning,the working tree is not clean; the archive holds HEAD only); \
	fi
	pdf=`$(GIT) log -1 --format=%H -- $(TARGET).pdf`; \
	if [ -z "$$pdf" ] || \
	   [ -n "`$(GIT) rev-list -1 $$pdf..HEAD -- $(SRC)`" ]; then \
	  $(call msgerror,$(TARGET).pdf in HEAD is out of date: run make and commit it); \
	  $(GIT) --no-pager log --oneline $$pdf..HEAD -- $(SRC); \
	  exit 1; \
	fi
	mkdir -p build
	$(GIT) -c core.autocrlf=false -c tar.umask=0022 archive --format=tar.gz \
	  --prefix=$(PACKAGE)/ \
	  --output=$(CTAN_ARCHIVE) HEAD
	$(call msgtarget,Archive for CTAN,$(CTAN_ARCHIVE))
	$(TAR) -tvzf $(CTAN_ARCHIVE)
