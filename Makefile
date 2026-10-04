.PHONY: audit test sepri test-sepri lint-r

audit:
	python3 scripts/audit_tables.py

test:
	python3 -m unittest discover -s tests -v

sepri:
	Rscript scripts/sepri_analysis.R

test-sepri:
	Rscript tests/test_sepri.R

lint-r:
	Rscript -e 'x <- c(lintr::lint("scripts/sepri_analysis.R"), lintr::lint("tests/test_sepri.R")); print(x); stopifnot(length(x) == 0)'
