import 'package:json_schema/json_schema.dart';
import 'package:test/test.dart';

main() {
  JsonSchema fooSchema;
  setUp(() async {
    fooSchema = await JsonSchema.createAsync({
      '\$defs': {
        'a': {
          'const': 'found in ref',
          'deeper': {'const': 'deeper in the schema'},
          '\$ref': '#/\$defs/b'
        },
        'b': {'const': 'b in not resolved'}
      },
      'properties': {
        'foo': {'\$ref': '#/\$defs/a'},
        'baz': {
          '\$ref': '#/\$defs/a',
          'findMe': {'const': 'is found'}
        }
      }
    }, schemaVersion: SchemaVersion.draft2020_12);
  });
  group('Resolve path', () {
    test('ref resolved immediately when it is the only property.', () {
      var ref = fooSchema.resolvePath(Uri.parse('#/properties/foo'));
      expect(ref.constValue, 'found in ref');
    });

    test('ref should not resolve when there are multiple properties', () {
      var ref = fooSchema.resolvePath(Uri.parse('#/properties/baz'));
      expect(ref.constValue, null);
      expect(ref.ref == null, false);
    });

    test('should continue resolving in the current node even if there is a ref', () {
      final schema = fooSchema.resolvePath(Uri.parse('#/properties/baz/findMe'));
      expect(schema.constValue, 'is found');
    });
  });
}
