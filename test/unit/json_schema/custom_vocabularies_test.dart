import 'package:json_schema/json_schema.dart';
import 'package:json_schema/src/json_schema/format_exceptions.dart';
import 'package:json_schema/src/json_schema/type_validators.dart';
import 'package:test/test.dart';

main() {
  var ck = CustomVocabulary(
    Uri.parse("http://localhost:4321/vocab/min-date"),
    {"minDate": KeywordProcessor(_minDateSetter, _validateMinDate)},
  );
  group("Custom Vocabulary Tests", () {
    test('Should process custom vocabularies and validate', () async {
      final schema = await JsonSchema.createAsync(
        {
          r'$schema': 'http://localhost:4321/date-keyword-meta-schema.json',
          r'$id': 'http://localhost:4321/date-keword-schema',
          'properties': {
            "publishedOn": {"minDate": "2020-12-01"},
            "baz": {"type": "string"}
          },
          "required": ["baz", "publishedOn"]
        },
        schemaVersion: SchemaVersion.draft2020_12,
        customKeyword: ck,
      );

      expect(schema.properties["publishedOn"].customSetAttributes.keys.contains("minDate"), true);

      expect(schema.validate({'baz': 'foo', 'publishedOn': '2970-01-01'}).isValid, true);
      expect(schema.validate({'baz': 'foo', 'publishedOn': '1970-01-01'}).isValid, false);
    });

    // test('Can throw an exception', () async {
    //   final catchException = expectAsync1((e) {
    //     expect(e is FormatException, true);
    //   });
    //   try {
    //     await JsonSchema.createAsync(
    //       {
    //         r'$schema': 'http://localhost:4321/date-keyword-meta-schema.json',
    //         r'$id': 'http://localhost:4321/date-keword-schema',
    //         'properties': {
    //           "publishedOn": {"minDate": 42}
    //         }
    //       },
    //       schemaVersion: SchemaVersion.draft2020_12,
    //       customKeyword: ck,
    //     );
    //   } catch (e) {
    //     catchException(e);
    //   }
    // });
  });
}

Object _minDateSetter(JsonSchema s, Object value) {
  var valueStr = TypeValidators.nonEmptyString("minDate", value);
  try {
    return DateTime.parse(valueStr);
  } catch (e) {
    throw FormatExceptions.error("minDate must parse as a date: ${value}");
  }
}

CustomValidationResult _validateMinDate(Object schema, Object instance) {
  if (schema is! DateTime) {
    return CustomValidationResult.error('schema is not a date time object.');
  }
  DateTime minDate = schema;
  if (instance is! String) {
    return CustomValidationResult.error('Data is not stringy');
  }
  String instanceString = instance;
  try {
    var testDate = DateTime.parse(instanceString);
    if (minDate.isAfter(testDate)) {
      return CustomValidationResult.error('min date is after given date');
    }
    return CustomValidationResult.passed();
  } catch (e) {
    return CustomValidationResult.error('unable to parse date');
  }
}
