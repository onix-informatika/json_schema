import 'package:json_schema/src/json_schema/constants.dart';
import 'package:json_schema/src/json_schema/validation_context.dart';

ValidationContext defaultIpv4Validator(ValidationContext context, SchemaVersion schemaVersion, String instanceData) {
  if (JsonSchemaValidationRegexes.ipv4.firstMatch(instanceData) == null) {
    context.addError('"ipv4" format not accepted $instanceData');
  }
  return context;
}
