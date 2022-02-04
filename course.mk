subject_code := 1047
probl_units := \
	02 \
	03 \
	06 \
	07 \
	08 \
	09 \
	11 \
	12 \
	50 \
	51

probl_figs := \
	03

with_ans_es := $(addsuffix _$(subject_code)-es, \
	$(addprefix prsol-, $(probl_units)))

no_ans_es := $(addsuffix _$(subject_code)-es, \
	$(addprefix prhdout-, $(probl_units)))

docs_es := $(no_ans_es) $(with_ans_es)

docs_base := $(docs_es)
docs_pdf := $(addprefix $(outdir)/, $(addsuffix .pdf, $(docs_base)))

## Automatic dependencies
## ================================================================================
docs_deps := $(addprefix $(depsdir)/, \
	$(addsuffix .pdf.d, $(docs_base)))

tex_deps := $(addprefix $(depsdir)/probl-, \
	$(addsuffix _$(subject_code)-es.tex.d, $(units)))

probl_figs_deps := $(addprefix $(depsdir)/probl-,\
	$(addsuffix _$(subject_code)-figs.d, $(probl_figs)))

all_deps := $(docs_deps) $(tex_deps) $(probl_figs_deps)
