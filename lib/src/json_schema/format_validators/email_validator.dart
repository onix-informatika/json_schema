import 'package:json_schema/src/json_schema/constants.dart';
import 'package:json_schema/src/json_schema/utils.dart';
import 'package:json_schema/src/json_schema/validation_context.dart';

ValidationContext defaultEmailValidator(ValidationContext context, SchemaVersion schemaVersion, String instanceData) {
  final isValid = DefaultValidators().emailValidator ?? (_) => false;

  if (!isValid(instanceData)) {
    context.addError('"email" format not accepted $instanceData');
  }
  return context;
}
