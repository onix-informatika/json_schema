import 'package:json_schema/src/json_schema/constants.dart';
import 'package:json_schema/src/json_schema/utils.dart';
import 'package:json_schema/src/json_schema/validation_context.dart';

ValidationContext defaultIriReferenceValidator(
    ValidationContext context, SchemaVersion schemaVersion, String instanceData) {
  if (SchemaVersion.draft7 != schemaVersion) return context;

  // Dart's URI class supports parsing IRIs, so we can use the same validator
  final isValid = DefaultValidators().uriReferenceValidator ?? (_) => false;

  if (!isValid(instanceData)) {
    context.addError('"iri-reference" format not accepted $instanceData');
  }
  return context;
}
