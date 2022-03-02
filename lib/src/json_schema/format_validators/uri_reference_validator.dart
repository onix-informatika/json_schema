import 'package:json_schema/src/json_schema/constants.dart';
import 'package:json_schema/src/json_schema/global_platform_functions.dart';
import 'package:json_schema/src/json_schema/validation_context.dart';

ValidationContext defaultUriReferenceValidator(
    ValidationContext context, SchemaVersion schemaVersion, String instanceData) {
  if (![SchemaVersion.draft6, SchemaVersion.draft7].contains(schemaVersion)) return context;
  final isValid = defaultValidators.uriReferenceValidator ?? (_) => false;

  if (!isValid(instanceData)) {
    context.addError('"uri-reference" format not accepted $instanceData');
  }
  return context;
}
