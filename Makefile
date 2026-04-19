SHELL := /bin/bash

.PHONY: versions build-all build-base-os build-base-conda build-runtime run test release

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
