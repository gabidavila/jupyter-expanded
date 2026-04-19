SHELL := /bin/bash

.PHONY: help versions build-all build-base-os build-base-conda build-runtime run test release

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  versions       Show all versions from versions.yaml"
	@echo "  build-all      Build all three Docker images"
	@echo "  build-base-os  Build base OS image only"
	@echo "  build-base-conda  Build base conda image only"
	@echo "  build-runtime  Build runtime image only"
	@echo "  run            Run container interactively"
	@echo "  test           Run smoke tests"
	@echo "  release        Tag and push release images"

versions:
	./scripts/tools/versions.sh

build-all:
	./scripts/build/all.sh

build-base-os:
	./scripts/build/base-os.sh

build-base-conda:
	./scripts/build/base-conda.sh

build-runtime:
	./scripts/build/runtime.sh

run:
	./scripts/run/local.sh

test:
	./scripts/test/runtime.sh

release:
	./scripts/release/tags.sh
