import 'package:json_schema/src/json_schema/constants.dart';
import 'package:json_schema/src/json_schema/validation_context.dart';

ValidationContext defaultRelativeJsonPointerValidator(
    ValidationContext context, SchemaVersion schemaVersion, String instanceData) {
  // TODO: support on later drafts.
  if (SchemaVersion.draft7 != schemaVersion) return context;
  if (JsonSchemaValidationRegexes.relativeJsonPointer.firstMatch(instanceData) == null) {
    context.addError('"relative-json-pointer" format not accepted $instanceData');
  }
  return context;
}
