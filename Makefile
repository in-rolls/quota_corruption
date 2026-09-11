.PHONY: audit test

audit:
	python3 scripts/audit_tables.py

test:
	python3 -m unittest discover -s tests -v
