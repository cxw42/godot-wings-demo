# Makefile --- commonly-used shortcuts for Godot development

#HERE := $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

.PHONY: all
all:
	@echo 'Targets: venv, p (to pretty-print), clean'

# Re-create the virtual environment
.PHONY: venv
venv:
	-deactivate ; rm -rf venv
	python3.12 -m venv venv
	deactivate ; . venv/bin/activate && python -m pip install --upgrade pip && \
		python -m pip install -r requirements-dev.txt
	touch venv/.gdignore

# Pretty-print GDScript files
.PHONY: p
p:
	git status --porcelain=v1 | \
		awk -- '/^( [MTDRC]|AU|UA|AA|UU|[AM])/ {print $$NF}' | \
		sort -u | \
		grep -E '\.gd$$' | \
		grep -E -v '^addons' | \
		xargs -r gdformat

.PHONY: clean
clean:
	git clean -dfx
