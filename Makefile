.PHONY: build changes clean coverage-server dependencies
.DEFAULT_GOAL := .last-build

charm_name := $(shell grep -Eo "^name: *[\"']([A-Za-z0-9\-]*)[\"']" metadata.yaml | sed -E 's/^name: *[\"'\'']([A-Za-z0-9\-]*)[\"'\'']/\1/g')

# WARNING: Use the all argument  only while developing the template, not when developing charms
ifndef all
	requirements=""
else
	requirements=requirements*.txt
endif

# PHONY GOALS

build: .last-build

clean:
	@pip uninstall -y -r requirements.txt -r requirements-dev.txt 2>/dev/null || true
	@pip uninstall -y pip-tools 2>/dev/null || true
	@rm -fv .last* *.charm .coverage ${requirements}
	@rm -rfv build/ *.egg-info **/__pycache__ .pytest_cache .tox htmlcov

coverage-server:
	@cd htmlcov && python3 -m http.server 5000

dependencies: .last-pip-tools-install .last-pip-sync

test: .last-pip-sync .last-pip-tools-install
	pytest --capture=no -vv

# REAL GOALS

.last-pip-sync: requirements-dev.txt requirements.txt
	@(pip-sync requirements-dev.txt requirements.txt || echo "pip-sync error") | tee .last-pip-sync
	@(grep "pip-sync error" .last-pip-sync 1>/dev/null 2>&1 && rm -f .last-pip-sync && exit 1) || true
	@pyenv rehash

.last-build: src/* .last-pip-sync metadata.yaml config.yaml
	@echo "Building ${charm_name}.charm..."
	@rm -rf build && python3 setup.py build | tee .last-build
	@mkdir -p build/hooks | tee -a .last-build
	@cp hook-wrapper build/dispatch | tee -a .last-build
	@cp hook-wrapper build/hooks/upgrade-charm | tee -a .last-build
	@cp hook-wrapper build/hooks/install | tee -a .last-build
	@cp hook-wrapper build/hooks/start | tee -a .last-build
	@cp metadata.yaml build/ | tee -a .last-build
	@cp config.yaml build/ | tee -a .last-build
	@rm -f ${charm_name}.charm | tee -a .last-build
	@zip --help 1>/dev/null 2>&1 || sudo apt install zip
	@cd build && zip -r ../${charm_name}.charm .

.last-pip-tools-install:
	@(pip-compile --version 1>/dev/null 2>&1 || pip --disable-pip-version-check install "pip-tools>=5.3.0,<5.4" || echo "pip-tools install error") | tee .last-pip-tools-install
	@(grep "pip-tools install error" .last-pip-tools-install 1>/dev/null 2>&1 && rm -f .last-pip-tools-install && exit 1) || true

requirements.txt: setup.py
	@CUSTOM_COMPILE_COMMAND="make dependencies" pip-compile

requirements-dev.txt: requirements-dev.in requirements.txt
	@CUSTOM_COMPILE_COMMAND="make dependencies" pip-compile  requirements-dev.in
