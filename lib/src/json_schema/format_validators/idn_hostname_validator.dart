import 'package:json_schema/src/json_schema/constants.dart';
import 'package:json_schema/src/json_schema/validation_context.dart';

ValidationContext defaultIdnHostnameValidator(
    ValidationContext context, SchemaVersion schemaVersion, String instanceData) {
  // Introduced in Draft 7
  if (schemaVersion.compareTo(SchemaVersion.draft7) < 0) return context;

  final regexp = schemaVersion.compareTo(SchemaVersion.draft2019_09) < 0
      ? JsonSchemaValidationRegexes.idnHostname
      // Updated in Draft 2019-09
      : JsonSchemaValidationRegexes.idnHostnameDraft2019;

  if (regexp.firstMatch(instanceData) == null) {
    context.addError('"idn-hostname" format not accepted $instanceData');
  }
  return context;
}
