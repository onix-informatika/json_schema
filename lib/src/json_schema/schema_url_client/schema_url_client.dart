import 'package:json_schema/json_schema.dart';

abstract class SchemaUrlClient {
  Future<JsonSchema> createSchemaFromUrl(String schemaUrl, {SchemaVersion schemaVersion});
}
