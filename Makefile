SHELL                    := /bin/bash

.PHONY: pubget
pubget:
	dart pub get

.PHONY: pubupgrade
pubupgrade:
	dart pub upgrade

.PHONY: dependency_validator
dependency_validator:
	dart run dependency_validator

.PHONY: format
format:
	dart format -l 120 .

.PHONY: analyze
analyze:
	dart analyze

# test recipe does the following:
# 1) starts a dart process to server specification test remotes
# 2) stores the pid of the serve_remotes.dart process
# 3) waits 3 seconds to give the server time to start
# 4) runs the tests
# 5) stores the exit code of the tests
# 6) stops the server
# 7) exits the process with the return code from the tests
.PHONY: test
test: 
	{ dart run ./tool/serve_remotes.dart & }; \
	pid=$$!; \
	sleep 3; \
	dart test; \
	r=$$?; \
	kill $$pid; \
	exit $$r