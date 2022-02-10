import 'package:json_schema/src/json_schema/typedefs.dart';

/// Register a custom vocabulary with the [JsonSchema] compiler.
class CustomVocabulary {
  CustomVocabulary(this._vocab, this._setters);

  Uri _vocab;
  Map<String, KeywordProcessor> _setters;

  Uri get vocab => _vocab;

  Map<String, KeywordProcessor> get setters => _setters;
}

/// A class to contain the set of functions for setting and validating keywords in a custom vocabulary.
class KeywordProcessor {
  KeywordProcessor(this._setter, this._validator);

  SchemaPropertySetter _setter;
  CustomValidationResult Function(Object, Object) _validator;

  SchemaPropertySetter get setter => this._setter;

  CustomValidationResult Function(Object, Object) get validator => this._validator;
}

/// Result object for a custom Validation function.
class CustomValidationResult {
  /// Use to return when a custom validation has passed.
  CustomValidationResult.passed() {
    this._pass = true;
  }

  /// Return a custom error message when a custom validation has errored.
  CustomValidationResult.error(String message) {
    this._pass = false;
    this._message = message;
  }

  bool _pass = false;
  String _message = "";

  bool get pass => _pass;

  String get message => _message;
}
