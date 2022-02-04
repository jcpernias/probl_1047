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

with_ans_es := $(addsuffix _$(subject_code)-es, \
	$(addprefix with-ans-probl-, $(probl_units)))

no_ans_es := $(addsuffix _$(subject_code)-es, \
	$(addprefix no-ans-probl-, $(probl_units)))

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
