// Internal class used as a key in a map for tracking resolved references.
import 'package:json_schema/src/json_schema/json_schema.dart';
import 'package:json_schema/src/json_schema/utils/utils.dart';

class SchemaPathPair {
  SchemaPathPair(this.schema, this.path);

  int _hashCode;

  final JsonSchema schema;
  final Uri path;

  @override
  toString() => path.toString();

  @override
  bool operator ==(Object other) =>
      other is SchemaPathPair && this.schema.hashCode == other.schema.hashCode && this.path == other.path;

  @override
  int get hashCode => _hashCode ?? (_hashCode = Hasher.hash2(this.schema.hashCode, this.path.hashCode));
}
