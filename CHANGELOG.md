## 4.0.0 (Tentative)

json_schema 4.0 continues our journey to support additional new versions of the JSON Schema specification (Draft 2019-09 and Draft 2020-12)! In addition to the new draft support, we have better support for certain formats, as well as improved spec test compliance. 

We have greatly reduced the number of dependencies in preparation for a null-safety release (which we're planning in another major release). This has also come with a new Makefile instead our old `dart_dev` based commands (see README).

- Support for JSON Schema Draft 2019-09
- Default Schema version is now 2019-09 (Breaking)
- Deprecated:
  - `validateWithResults` in favor of `validate` which now returns the same thing (`ValidationResults`).
- Removed Deprecations:
  - Removed `bin/schemadot.dart`, `lib/schema_dot.dart` and related examples
  - Removed `lib/browser.dart` and `lib/vm.dart` and associated globals `createSchemaFromUrlBrowser`, `configureJsonSchemaForBrowser`, `globalCreateJsonSchemaFromUrl` `createSchemaFromUrlVm`, `configureJsonSchemaForVm` and `resetGlobalTransportPlatform`. These were for configuring the runtime environment, which now happens automatically.
  - Removed `JsonSchema.createSchemaAsync` in favor of `JsonSchema.createAsync`
  - Removed `JsonSchema.createSchema` in favor of `JsonSchema.create`
  - Removed `JsonSchema.createSchemaFromUrl` in favor of `JsonSchema.createFromUrl`
  - Removed `RefProvider.asyncSchema`, `RefProvider.syncSchema`, `RefProvider.asyncJson`, and `RefProvider.syncJson` in favor of `RefProvider.async` and `RefProvider.async`, which are easier to use.
  - Removed `JsonSchema.refMap`
- Breaking change to `validate`:
  - now returns `ValidationResult` instead of `bool` like `validateWithResults` (now deprecated).

## 3.2.0

* Add `Validator.validateWithResults` (This new method gives the most complete and customizable validation results)
* Add `JsonSchema.validateWithResults`
* Deprecate `JsonSchema.validate`
* Deprecate `Validator.validate`
* Deprecate `JsonSchema.validateWithErrors`
* Deprecate `Validator.errors`
* Deprecate `Validator.errorObjects`

## 3.1.0

* Remove the need for separate browser and VM imports
* Deprecate non-json RefProviders
* More specific missing-required property errors

## 3.0.0

* Removed support for Dart 1

## 2.2.0

* Add note about root path in error string when instance path is empty
* Expose `ValidationError` class

## 2.1.4

* Use deep equality to compare maps, fixing equality when enums are present

## 2.1.3

* New `validateWithErrors` method on `JsonSchema` returns all validation errors as a list of objects
* `ValidationError` objects include both instance & schema paths for each error
* Error logic tweaked to provide consistent error paths in JSON pointer notation

## 2.0.0

* json_schema is no longer bound to dart:io and works in the browser!
* Full JSON Schema draft6 compatibility
* Much better $ref resolution, including deep nesting of $refs
* More typed keyword getters for draft6 like `examples`
* Synchronous schema evaluation by default
* Optional async evaluation and fetching with `createSchemaAsync`
* Automatic parsing of JSON strings passed to `createSchema` and `createSchemaAsync`
* Ability to do custom resolution of $refs with `RefProvider` and `RefProviderAsync`
* Optional parsing of JSON strings passed to `validate` with `parseJson = true`
* Dart 2.0 compatibility
* Many small changes to make things more in line with modern dart.
* Please see the [migration guide](./MIGRATION.md) for additional info.

## 1.0.8

* Code cleanup
* Strong mode
* Switch build tools to dart_dev

## 1.0.7

* Update dependency constraint on the `args` package.

## 1.0.3

* Add a dependency on the `args` package.

## 1.0.2

* Add a dependency on the `logging` package.
