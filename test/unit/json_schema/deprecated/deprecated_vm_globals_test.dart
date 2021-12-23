@TestOn('vm')

import 'package:json_schema/vm.dart';
import 'package:test/test.dart';

main() {
  group('deprecated global browser functions', () {
    test('should exist', () {
      // ignore: deprecated_member_use_from_same_package
      expect(() => createSchemaFromUrlVm('http://json-schema.org/draft-07/schema#'), returnsNormally);
    });
  });
}
