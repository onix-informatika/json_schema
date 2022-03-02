import 'package:json_schema/src/json_schema/constants.dart';
import 'package:json_schema/src/json_schema/validation_context.dart';

ValidationContext defaultIdnEmailValidator(
    ValidationContext context, SchemaVersion schemaVersion, String instanceData) {
  // No maintained dart packages exist to validate RFC6531,
  // and it's too complex for a regex, so best effort is to pass for now.
  return context;
}
