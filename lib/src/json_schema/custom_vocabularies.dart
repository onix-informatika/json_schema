import 'package:json_schema/src/json_schema/typedefs.dart';

import '../../json_schema.dart';

/// Use to register a custom vocabulary with the [JsonSchema] compiler.
///
class CustomVocabulary {
  CustomVocabulary(this._vocab, this._keywordImplementations);

  Uri _vocab;
  Map<String, CustomKeywordImplementation> _keywordImplementations;

  /// Name of the vocabulary.
  Uri get vocab => _vocab;

  /// A map of the keywords and implementation for the keywords.
  Map<String, CustomKeywordImplementation> get keywordImplementations => _keywordImplementations;
}

/// A class to contain the set of functions for setting and validating keywords in a custom vocabulary.
///
/// The two functions provided are used to process an attribute in a schema and then validate data.
///
/// The setter function takes the current JsonSchema node being processed and the data from the json.
/// The given function should validate and transform the data however is needed for the corresponding validation
/// function. If the data is bad a [FormatException] with a clear message should be thrown.
///
/// The validation function takes the output from the property setter and data from a JSON payload to be validated.
/// A [CustomValidationResult] should be returned to indicate the outcome of the validation.
class CustomKeywordImplementation {
  CustomKeywordImplementation(this._propertySetter, this._validator);

  Object Function(JsonSchema schema, Object value) _propertySetter;
  CustomValidationResult Function(Object schemaProperty, Object instanceData) _validator;

  /// Function used to set a property from the a schema.
  Object Function(JsonSchema schema, Object value) get propertySetter => this._propertySetter;

  /// Function used to validate a json value.
  CustomValidationResult Function(Object schemaProperty, Object instanceData) get validator => this._validator;
}

enum _ValidationState { valid, warning, error }

/// Result object for a custom Validation function.
class CustomValidationResult {
  /// Use to return a successful validation.
  CustomValidationResult.valid() {
    this._state = _ValidationState.valid;
  }

  /// Used to return a warning from a custom validator.
  CustomValidationResult.warning(String message) {
    this._state = _ValidationState.warning;
    this._message = message;
  }

  /// Used to return an error from a custom validator.
  CustomValidationResult.error(String message) {
    this._state = _ValidationState.error;
    this._message = message;
  }

  _ValidationState _state = _ValidationState.error;
  String _message = "";

  /// Returns true when the result passes.
  bool get valid => _state == _ValidationState.valid;

  /// Returns true when in an error state.
  bool get error => _state == _ValidationState.error;

  /// Returns true when in a warning state.
  bool get warning => _state == _ValidationState.warning;

  /// Custom message for errors and warnings.
  String get message => _message;
}
