import 'package:json_schema/src/json_schema/constants.dart';
import 'package:json_schema/src/json_schema/validation_context.dart';

ValidationContext defaultHostnameValidator(
    ValidationContext context, SchemaVersion schemaVersion, String instanceData) {
  final regexp = schemaVersion.compareTo(SchemaVersion.draft2019_09) < 0
      ? JsonSchemaValidationRegexes.hostname
      // Updated in Draft 2019-09
      : JsonSchemaValidationRegexes.hostnameDraft2019;

  if (regexp.firstMatch(instanceData) == null) {
    context.addError('"hostname" format not accepted $instanceData');
  }
  return context;
}
