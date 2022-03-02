import 'package:json_schema/src/json_schema/constants.dart';
import 'package:json_schema/src/json_schema/validation_context.dart';
import 'package:rfc_6901/rfc_6901.dart';

ValidationContext defaultJsonPointerValidator(
    ValidationContext context, SchemaVersion schemaVersion, String instanceData) {
  if (![SchemaVersion.draft6, SchemaVersion.draft7].contains(schemaVersion)) return context;
  try {
    JsonPointer(instanceData);
  } on FormatException catch (_) {
    context.addError('"json-pointer" format not accepted $instanceData');
  }
  return context;
}
