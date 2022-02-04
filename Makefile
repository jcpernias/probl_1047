SHELL := /bin/sh

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

emacsbin := /usr/bin/emacs
texi2dvibin := /usr/bin/texi2dvi
envbin  := /usr/bin/env
pythonbin := /usr/bin/python3
Rscriptbin := /usr/local/bin/Rscript

-include local.mk

## Variables
## ================================================================================

elisp_files := $(addprefix $(elispdir)/, setup-org.el parser.el)

EMACS := $(emacsbin) -Q -nw --batch
emacs_loads := $(addprefix --load=, $(elisp_files))
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

tex_check_dirs := $(builddir) $(figdir) $(depsdir)


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


include course.mk


common_tex_deps := \
	$(rootdir)/$(subject_code)-macros.tex \
	$(texdir)/docs-base.sty \
	$(rootdir)/course.cfg \
	$(rootdir)/hyperref.cfg

probl_tex_deps := \
	$(texdir)/probl.cls \
	$(texdir)/docs-full.sty \
	$(texdir)/docs-pages.sty \
	$(rootdir)/course-colors.cfg \
	$(rootdir)/probl.cfg \
	$(common_tex_deps)

fig_tex_deps := \
	$(texdir)/figure.cls \
	$(rootdir)/standalone.cfg \
	$(common_tex_deps)


## Rules
## ================================================================================

all: $(docs_pdf)

# org to latex

# dependencies for latex file
$(depsdir)/%.tex.d: $(rootdir)/%.org | $(depsdir)
	$(MAKEORGDEPS) -o $@ -t $(builddir)/$*.tex $<

# probl to latex
.PRECIOUS: $(builddir)/probl-%.tex
$(builddir)/probl-%.tex: $(rootdir)/probl-%.org $(elisp_files)| $(builddir)
	$(EMACS) $(emacs_loads) --visit=$< $(org_to_latex)

# probl wrappers
.PRECIOUS: $(builddir)/prhdout-%-es.tex
$(builddir)/prhdout-%-es.tex: $(builddir)/probl-%-es.tex \
  $(probl_tex_deps) | $(figdir)
	$(file > $@, $(call probl-wrapper,noanswers,probl-$*,es))

.PRECIOUS: $(builddir)/prsol-%-es.tex
$(builddir)/prsol-%-es.tex: $(builddir)/probl-%-es.tex \
  $(probl_tex_deps) | $(figdir)
	$(file > $@, $(call probl-wrapper,answers,probl-$*,es))

.PRECIOUS: $(builddir)/prhdout-%-en.tex
$(builddir)/prhdout-%-en.tex: $(builddir)/probl-%-en.tex \
  $(probl_tex_deps) | $(figdir)
	$(file > $@, $(call probl-wrapper,noanswers,probl-$*,en))

.PRECIOUS: $(builddir)/prsol-%-en.tex
$(builddir)/prsol-%-en.tex: $(builddir)/probl-%-en.tex \
  $(probl_tex_deps) | $(figdir)
	$(file > $@, $(call probl-wrapper,answers,probl-$*,en))


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
$(figdir)/fig-%.pdf: $(builddir)/fig-%.tex  \
  $(fig_tex_deps)| $(figdir)
	$(TEXI2DVI) --output=$@ $<

$(depsdir)/probl-%-figs.d: probl-%-figs.org | $(depsdir)
	$(MAKEFIGDEPS) -o $@ $<

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
