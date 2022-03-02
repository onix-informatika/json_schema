import 'package:json_schema/src/json_schema/constants.dart';
import 'package:json_schema/src/json_schema/utils.dart';
import 'package:json_schema/src/json_schema/validation_context.dart';

ValidationContext defaultUriTemplateValidator(
    ValidationContext context, SchemaVersion schemaVersion, String instanceData) {
  if (![SchemaVersion.draft6, SchemaVersion.draft7].contains(schemaVersion)) return context;
  final isValid = DefaultValidators().uriTemplateValidator ?? (_) => false;

  if (!isValid(instanceData)) {
    context.addError('"uri-template" format not accepted $instanceData');
  }
  return context;
}
