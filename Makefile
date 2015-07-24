MAKEFLAGS += -r -R -j $(shell getconf _NPROCESSORS_ONLN)

.SILENT :
.PHONY  : all clean cleanall

DOCUMENT := documentation
SRC := $(DOCUMENT).tex
SRC += $(wildcard *.cls)
SRC += $(wildcard *.sty)
DEPS := $(SRC) Makefile
TARGET   := documentation

PDFLATEX ?= pdflatex
BIBTEX ?= bibtex
DIFF ?= diff
GREP ?= grep
AWK ?= awk
LS ?= ls
MV ?= mv
SED ?= sed
UNIQ ?= uniq
SORT ?= sort

PDFLATEX_FLAGS	:= -interaction=batchmode -recorder -file-line-error
GREP_FLAGS += -E -B 1 -A 2

# terminal colors
ifneq ($(COLORTERM),false)
  NOCOLOR := "\033[0m"
  RED := "\033[1;31m"
  BLUE := "\033[1;34m"
  GREEN := "\033[1;32m"
  YELLOW := "\033[1;33m"
  CYAN := "\033[1;36m"
  WHITE := "\033[1;37m"
  MAGENTA := "\033[1;35m"
  BOLD := "\033[1m"
else
  NOCOLOR := ""
  RED := ""
  BLUE := ""
  GREEN := ""
  YELLOW := ""
  CYAN := ""
  WHITE := ""
  MAGENTA := ""
  BOLD := ""
endif

# helper functions for filename conversion
getname = $(firstword $(subst ., ,$(1)))
getaux = $(call getname,$(1)).aux

# messaging functions
msgtarget = printf $(GREEN)"%s"$(MAGENTA)" %s"$(NOCOLOR)"\n" "$(1)" "$(2)"
msgcompile = printf $(BOLD)"%-25s"$(NOCOLOR)" %s\n" "[$(1)]" "$(2)"
msgfail = printf "%-25s "$(RED)"%s"$(NOCOLOR)"\n" "" "FAILED! Continuing ..."
msginfo = printf "%-25s "$(CYAN)"%s"$(NOCOLOR)"\n" "" "$(1)"

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

define run-bibtex
  $(call msgcompile,$(BIBTEX),$(call getaux,$(1))); \
  $(BIBTEX) $(BIB_FLAGS) $(call getaux,$(1)) 1>/dev/null 2>&1 || \
    $(call msgfail)
endef

define grep-citation
  $(GREP) $(GREP_FLAGS) -e "Warning: Citation .*" \
    $(call getlog,$(1)) 1>/dev/null 2>&1
endef

define check-citation
  $(GREP) -e'^\\citation' $(call getaux,$(1)) 2>/dev/null \
    >$(call gettemp,$(1)); \
  $(DIFF) $(call gettemp,$(1)) $(call getcit,$(1)) 1>/dev/null 2>&1 || \
        (mv -f $(call gettemp,$(1)) $(call getcit,$(1)); false)
endef

define grep-crossref
  $(GREP) $(GREP_FLAGS) -e "Rerun to get .*" \
    $(call getlog,$(1)) 1>/dev/null 2>&1 && \
    $(call msginfo,Rerun latex to get everything right.)
endef

define extract-log
  $(call msgtarget,Extracting log file for target,$(1)); \
  $(GREP) -E -v -e "^<Error-correction level increased from . to . at no cost\\.>$$" $(call getname,$(1)).log | \
  $(GREP) $(GREP_FLAGS) -e ":[[:digit:]]+: |Warning|Error|Underfull|Overfull|\!|Reference|Label|Citation" || :
endef

# based on https://github.com/shiblon/latex-makefile/blob/master/get-inputs.sed
# $(call get-inputs,<jobname>,<target>)
define get-inputs
$(SED) \
-e '/^INPUT/!d' \
-e 's!^INPUT \(\./\)\{0,1\}!!' \
-e 's/[[:space:]]/\\ /g' \
-e 's/\(.*\)\.aux$$/\1.tex/' \
-e '/\.out$$/d' \
-e '/^\/dev\/null$$/d' \
-e 's!.*!$2: &!' \
'$1.fls' | grep -v ': $1.tex$$' | $(SORT) | $(UNIQ)
endef

.PHONY: $(DOCUMENT)
#$(DOCUMENT): $(TARGET).pdf
# use hard coded for shell completion
exam: $(TARGET).pdf

-include $(DOCUMENT).d
$(TARGET).pdf: TARGET_PDFLATEX_FLAGS = -output-directory=build/$(DOCUMENT)
$(TARGET).pdf: $(DEPS)
#	$(call run-typeset,$<)
#	$(call run-bibtex,$<)
	mkdir -p build/$(DOCUMENT)
	$(call run-draft-typeset,$<)
	$(call run-typeset,$<)
	$(call extract-log,build/$(DOCUMENT)/$(DOCUMENT))
	$(call get-inputs,build/$(DOCUMENT)/$(DOCUMENT),$@) > build/$(DOCUMENT)/$(DOCUMENT).d
	$(MV) build/$(DOCUMENT)/$(DOCUMENT).pdf "$@"

all: $(DOCUMENT)

clean:
	rm -fv *.aux
	rm -fv *.log
	rm -fv *.toc
	rm -fv *.lof
	rm -fv *.lot
	rm -fv *.eps
	rm -fv *.bbl
	rm -fv *.out
	rm -fv *.fls
	rm -fv *.blg
	rm -fv *.auxlock
	rm -fv *.nav
	rm -fv *.snm

cleanall: clean
	rm -fv *.pdf
	rm -rf build

fresh: cleanall
	$(MAKE) all
