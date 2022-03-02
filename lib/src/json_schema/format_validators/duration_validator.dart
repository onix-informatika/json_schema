import 'package:json_schema/src/json_schema/constants.dart';
import 'package:json_schema/src/json_schema/validation_context.dart';

ValidationContext defaultDurationValidator(
    ValidationContext context, SchemaVersion schemaVersion, String instanceData) {
  if (SchemaVersion.draft2019_09.compareTo(schemaVersion) > 0) return context;
  if (JsonSchemaValidationRegexes.duration.firstMatch(instanceData) == null) {
    context.addError('"duration" format not accepted $instanceData');
  }
  return context;
}
