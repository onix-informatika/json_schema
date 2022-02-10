import 'package:json_schema/json_schema.dart';

abstract class SchemaUrlClient {
  Future<JsonSchema> createFromUrl(
    String schemaUrl, {
    SchemaVersion schemaVersion,
    CustomVocabulary customKeyword,
  });

  Future<Map<String, dynamic>> getSchemaJsonFromUrl(String schemaUrl);
}
