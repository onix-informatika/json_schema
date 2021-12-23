import 'package:json_schema/json_schema.dart';
import 'package:json_schema/src/json_schema/global_platform_functions.dart';
import 'package:test/test.dart';

main() {
  group('deprecated global functions', () {
    test('should exist', () {
      // ignore: deprecated_member_use_from_same_package
      expect(() => globalCreateJsonSchemaFromUrl('http://json-schema.org/draft-07/schema#'), returnsNormally);
      // ignore: deprecated_member_use_from_same_package
      expect(() => resetGlobalTransportPlatform(), returnsNormally);
      expect(
          // ignore: deprecated_member_use_from_same_package
          () => globalCreateJsonSchemaFromUrl = (String schema, {SchemaVersion schemaVersion}) {
                return null;
              },
          returnsNormally);
    });
  });
}
