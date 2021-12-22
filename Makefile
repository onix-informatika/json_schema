SHELL                    := /bin/bash

.PHONY: pubget
pubget:
	dart pub get

.PHONY: dependency_validator
dependency_validator:
	dart run dependency_validator

.PHONY: format
format:
	dart format -l 120 .

.PHONY: analyze
analyze:
	dart analyze

.PHONY: test
test:
	dart test