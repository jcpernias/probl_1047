subject_code := 1047
probl_units := \
	02a \
	02b \
	05 \
	06 \
	07 \
	08 \
	09 \
	11 \
	12 \
	13 \
	50 \
	51

probl_figs := \
	04 \
	12


LANGUAGES := es


probl_suffixes := $(addprefix _$(subject_code)-, $(LANGUAGES))
probl_prefixes := $(addprefix prhdout-,$(probl_units)) \
  $(addprefix prsol-,$(probl_units))
probl_base := $(foreach suffix,$(probl_suffixes),\
  $(addsuffix $(suffix),$(probl_prefixes)))
probl_pdf := $(addprefix $(outdir)/, $(addsuffix .pdf, $(probl_base)))


docs_pdf := $(probl_pdf)

## Automatic dependencies
## ================================================================================
probl_deps := $(addprefix $(depsdir)/, $(addsuffix .pdf.d, $(probl_base)))

probl_tex_deps := $(addprefix $(depsdir)/probl-, \
	$(addsuffix _$(subject_code)-es.tex.d, $(probl_units)))

probl_figs_deps := $(addprefix $(depsdir)/probl-,\
	$(addsuffix _$(subject_code)-figs.d, $(probl_figs)))

all_deps := $(probl_deps) $(probl_tex_deps) $(probl_figs_deps)
