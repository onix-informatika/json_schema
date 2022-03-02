import 'package:json_schema/src/json_schema/constants.dart';
import 'package:json_schema/src/json_schema/utils.dart';
import 'package:json_schema/src/json_schema/validation_context.dart';

ValidationContext defaultUriValidator(ValidationContext context, SchemaVersion schemaVersion, String instanceData) {
  final isValid = DefaultValidators().uriValidator ?? (_) => false;
  if (!isValid(instanceData)) {
    context.addError('"uri" format not accepted $instanceData');
  }
  return context;
}
