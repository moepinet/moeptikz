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
