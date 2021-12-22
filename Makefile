SHELL                    := /bin/bash

.PHONY: pubget
pubget:
	dart pub get

.PHONY: format
format:
	dart format -l 120 .

.PHONY: analyze
analyze:
	dart analyze

.PHONY: test
test:
	dart test