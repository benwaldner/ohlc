# Generic Python Project Makefile
# ===============================
# Build and test Python projects using the targets from this Makefile.
# It uses pyclean, flake8, pytest, tox, and setuptools to test and package
# the Python code. It expects the following project structure.
#
#     -/package/              # A directory with the same name as the package
#     ./package/__init__.py   # contains all Python source code.
#     ./package/__main__.py   # Including the packages main function
#     ./package/module.py     # and other modules of the package.
#     ./tests/test_module.py  # A `tests` dir contains all tests, separate from the source.
#     ./tests/test-cli.sh     # The tests mus include script test the packages command line tools
#
# Building and Testing
# --------------------
# To "build" this Python project just run the tests via `make`.
# The default target will then cleanup the project dir and run the tests.
#
# Packaging
# ---------
# To package the project run `make build` and use the Python wheels in ./dist
# as packages for your needs. For pypi integration, please see `setup.mk`

PY       := 3
_PYTHON  := python$(PY)
_PIP     := pip$(PY)
_PACKAGE := $(shell $(_PYTHON) setup.py --name)

unexport PYTHONPATH

.PHONY: all clean tox test build install uninstall test-cli

all: clean tox

# Test and Build Targets
clean: ; rm -rf dist; pyclean .; true
tox:   ; which tox || pip install tox; tox
test:
	# running linter + basic tests using $(shell $(_PYTHON) --version)
	$(_PYTHON) -m flake8 $(_PACKAGE)
	$(_PYTHON) -m pytest -x tests

build: clean tox
	# building python wheel for publishing to pypi
	$(_PYTHON) setup.py bdist_wheel

# Manual Installation and Packaging Targets (for develpment only)
install:      tox ; $(_PIP) install -e .
user-install: tox ; $(_PIP) install --user -e .
uninstall:        ; $(_PIP) uninstall -y $(_PACKAGE) || true
test-cli:         ; tests/test-cli.sh
