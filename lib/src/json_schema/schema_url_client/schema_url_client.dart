import 'package:json_schema/json_schema.dart';
import 'package:json_schema/src/json_schema/validation_context.dart';

abstract class SchemaUrlClient {
  Future<JsonSchema> createFromUrl(
    String schemaUrl, {
    SchemaVersion schemaVersion,
    List<CustomVocabulary> customVocabularies,
    Map<String, ValidationContext Function(ValidationContext context, SchemaVersion schemaVersion, String instanceData)>
        customFormats = const {},
  });

  Future<Map<String, dynamic>> getSchemaJsonFromUrl(String schemaUrl);
}
