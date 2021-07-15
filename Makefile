SHELL := /bin/sh

subject_code := 1047
probl_units := \
	Size \
	Efficiency-Equity \
	Public-Goods \
	Externalities \
	Public-Choice \
	Cost-Benefit \
	Tax-Incidence \
	Tax-Efficiency \
	Eval3 \
	Eval4

probl_figs := \
	Efficiency-Equity

## Directories
## ================================================================================

rootdir := .
builddir := $(rootdir)/build
outdir := $(rootdir)/pdf
elispdir := $(rootdir)/elisp
pythondir := $(rootdir)/python
Rdir := $(rootdir)/R
texdir := $(rootdir)/tex
depsdir := $(rootdir)/.deps
imgdir := $(rootdir)/img
figdir := $(rootdir)/figures

## Programs
## ================================================================================

emacsbin := /usr/local/bin/emacs
texi2dvibin := /usr/local/opt/texinfo/bin/texi2dvi
envbin  := /usr/local/opt/coreutils/libexec/gnubin/env
pythonbin := /usr/local/bin/python3
Rscriptbin := /usr/local/bin/Rscript

## Variables
## ================================================================================

EMACS := $(emacsbin) -Q -nw --batch
emacs_loads := --load=$(elispdir)/setup-org.el \
	--load=$(elispdir)/parser.el
org_to_latex := --eval "(tolatex (file-name-as-directory \"$(builddir)\"))"
org_to_beamer := --eval "(tobeamer (file-name-as-directory \"$(builddir)\"))"
tangle := --eval "(tangle-to (file-name-as-directory \"$(builddir)\"))"

LATEX_MESSAGES := no
TEXI2DVI_FLAGS := --batch -I $(texdir) --pdf \
	--build=tidy --build-dir=$(notdir $(builddir))

ifneq ($(LATEX_MESSAGES), yes)
TEXI2DVI_FLAGS += -q
endif

TEXI2DVI := $(envbin) TEXI2DVI_USE_RECORDER=yes \
	$(texi2dvibin) $(TEXI2DVI_FLAGS)

MAKEORGDEPS := $(pythonbin) $(pythondir)/makeorgdeps.py
MAKETEXDEPS := $(pythonbin) $(pythondir)/maketexdeps.py
MAKEFIGDEPS := $(pythonbin) $(pythondir)/makefigdeps.py

RSCRIPT := $(Rscriptbin) -e

with_ans_es := $(addsuffix _$(subject_code)-es, \
	$(addprefix with-ans-probl-, $(probl_units)))

no_ans_es := $(addsuffix _$(subject_code)-es, \
	$(addprefix no-ans-probl-, $(probl_units)))

docs_es := $(no_ans_es) $(with_ans_es)

docs_base := $(docs_es)
docs_pdf := $(addprefix $(outdir)/, $(addsuffix .pdf, $(docs_base)))

tex_check_dirs := $(builddir) $(figdir) $(depsdir)

## Automatic dependencies
## ================================================================================
docs_deps := $(addprefix $(depsdir)/, \
	$(addsuffix .pdf.d, $(docs_base)))

tex_deps := $(addprefix $(depsdir)/unit-, \
	$(addsuffix _$(subject_code)-es.tex.d, $(units)))

probl_figs_deps := $(addprefix $(depsdir)/probl-,\
	$(addsuffix _$(subject_code)-figs.d, $(probl_figs)))

all_deps := $(docs_deps) $(tex_deps) $(probl_figs_deps)

FIGURES :=

INCLUDEDEPS := yes

# Do not include dependency files if make goal is some kind of clean
ifneq (,$(findstring clean,$(MAKECMDGOALS)))
INCLUDEDEPS := no
endif

# $(call tex-wrapper,pres-or-hdout,tex-src,lang) -> write to a file
define tex-wrapper
\PassOptionsToClass{$1}{unit}
\RequirePackage{etoolbox}
\AtEndPreamble{%
  \graphicspath{{$(realpath $(figdir))/}{$(realpath $(imgdir))/}}%
  \InputIfFileExists{$(subject_code)-macros.tex}{}{}%
  \InputIfFileExists{$2-macros.tex}{}{}}
\input{$(realpath $(builddir))/$2-$3}
endef

# $(call probl-wrapper,ans-option,tex-src,lang) -> write to a file
define probl-wrapper
\PassOptionsToClass{$1}{probl}
\RequirePackage{etoolbox}
\AtEndPreamble{%
  \graphicspath{{$(realpath $(figdir))/}{$(realpath $(imgdir))/}}%
  \InputIfFileExists{$(subject_code)-macros.tex}{}{}%
  \InputIfFileExists{$2-macros.tex}{}{}}
\input{$(realpath $(builddir))/$2-$3}
endef


# $(call tex-wrapper,spanish-or-english,fig-basename,unit-code) -> write to a file
define fig-wrapper
\documentclass[$1]{figure}
\InputIfFileExists{$(subject_code)-macros.tex}{}{}
\InputIfFileExists{unit-$3-macros.tex}{}{}
\begin{document}
\input{$(realpath $(builddir))/$2}
\end{document}
endef


# $(call knit,in,out)
define knit
"source(\"./R/common.R\"); library(knitr); options(knitr.package.root.dir=\"${rootdir}\"); knit(\"$1\", \"$2\")"
endef

## Rules
## ================================================================================

all: $(docs_pdf)

# org to latex
.PRECIOUS: $(builddir)/%.tex
$(builddir)/%.tex: $(rootdir)/%.org | $(builddir)
	$(EMACS) $(emacs_loads) --visit=$< $(org_to_beamer)

# dependencies for latex file
$(depsdir)/%.tex.d: $(rootdir)/%.org | $(depsdir)
	$(MAKEORGDEPS) -o $@ -t $(builddir)/$*.tex $<

# probl to latex
.PRECIOUS: $(builddir)/probl-%.tex
$(builddir)/probl-%.tex: $(rootdir)/probl-%.org | $(builddir)
	$(EMACS) $(emacs_loads) --visit=$< $(org_to_latex)

# probl wrappers
.PRECIOUS: $(builddir)/no-ans-probl-%-es.tex
$(builddir)/no-ans-probl-%-es.tex: $(builddir)/probl-%-es.tex | $(figdir)
	$(file > $@, $(call probl-wrapper,noanswers,probl-$*,es))

.PRECIOUS: $(builddir)/with-ans-probl-%-es.tex
$(builddir)/with-ans-probl-%-es.tex: $(builddir)/probl-%-es.tex | $(figdir)
	$(file > $@, $(call probl-wrapper,answers,probl-$*,es))

.PRECIOUS: $(builddir)/no-ans-probl-%-en.tex
$(builddir)/no-ans-probl-%-en.tex: $(builddir)/probl-%-en.tex | $(figdir)
	$(file > $@, $(call probl-wrapper,noanswers,probl-$*,en))

.PRECIOUS: $(builddir)/with-ans-probl-%-en.tex
$(builddir)/with-ans-probl-%-en.tex: $(builddir)/probl-%-en.tex | $(figdir)
	$(file > $@, $(call probl-wrapper,answers,probl-$*,en))



# latex wrappers
.PRECIOUS: $(builddir)/pres-%-es.tex
$(builddir)/pres-%-es.tex: $(builddir)/unit-%-es.tex | $(figdir)
	$(file > $@, $(call tex-wrapper,Presentation,unit-$*,es))

.PRECIOUS: $(builddir)/hdout-%-es.tex
$(builddir)/hdout-%-es.tex: $(builddir)/unit-%-es.tex | $(figdir)
	$(file > $@, $(call tex-wrapper,Handout,unit-$*,es))

.PRECIOUS: $(builddir)/pres-%-en.tex
$(builddir)/pres-%-en.tex: $(builddir)/unit-%-en.tex | $(figdir)
	$(file > $@, $(call tex-wrapper,Presentation,unit-$*,en))

.PRECIOUS: $(builddir)/hdout-%-en.tex
$(builddir)/hdout-%-en.tex: $(builddir)/unit-%-en.tex | $(figdir)
	$(file > $@, $(call tex-wrapper,Handout,unit-$*,en))

## latex to pdf
$(outdir)/%.pdf: $(builddir)/%.tex | $(outdir)
	$(TEXI2DVI) --output=$@ $<

# pdf dependencies
$(depsdir)/%.pdf.d: $(builddir)/%.tex | $(outdir) $(depsdir)
	$(MAKETEXDEPS) -o $@ -t $(outdir)/$*.pdf $<

# figure wrappers
.PRECIOUS: $(builddir)/fig-%-en.tex
$(builddir)/fig-%-en.tex: $(builddir)/fig-%.tex
	$(file > $@, $(call fig-wrapper,en,fig-$*,$(shell echo $* | sed 's/\([^-]*\)-.*/\1/')))

.PRECIOUS: $(builddir)/fig-%-es.tex
$(builddir)/fig-%-es.tex: $(builddir)/fig-%.tex
	$(file > $@, $(call fig-wrapper,es,fig-$*,$(shell echo $* | sed 's/\([^-]*\)-.*/\1/')))

# figure latex to pdf
$(figdir)/fig-%.pdf: $(builddir)/fig-%.tex | $(figdir)
	$(TEXI2DVI) --output=$@ $<

$(depsdir)/probl-%-figs.d: probl-%-figs.org | $(depsdir)
	$(MAKEFIGDEPS) -o $@ $<

# from R to latex
$(builddir)/%.tex: $(builddir)/%.Rnw | $(builddir)
	$(RSCRIPT) $(call knit,$<,$@)

## automatic dependencies
ifeq ($(INCLUDEDEPS),yes)
include $(all_deps)
endif

## Auxiliary directories
## --------------------------------------------------------------------------------

$(outdir):
	mkdir $(outdir)

$(builddir):
	mkdir $(builddir)

$(depsdir):
	mkdir $(depsdir)

$(figdir):
	mkdir $(figdir)

## Cleaning rules
## --------------------------------------------------------------------------------

.PHONY: clean
clean:
	-@rm -rf $(figdir)
	-@rm -rf $(builddir)
	-@rm -rf $(depsdir)

.PHONY: veryclean
veryclean: clean
	-@rm -rf $(outdir)
