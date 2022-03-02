import 'package:json_schema/src/json_schema/constants.dart';
import 'package:json_schema/src/json_schema/validation_context.dart';

ValidationContext defaultDateTimeValidator(
    ValidationContext context, SchemaVersion schemaVersion, String instanceData) {
  try {
    DateTime.parse(instanceData);
  } catch (e) {
    context.addError('"date-time" format not accepted $instanceData');
  }
  return context;
}
