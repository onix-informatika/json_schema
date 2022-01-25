import 'package:json_schema/json_schema.dart';
import 'package:test/test.dart';

main() {
  test('Should respect configurable format validation', () {
    final schema = JsonSchema.create({
      'properties': {
        'someKey': {'format': 'uri-template'}
      }
    });

    final isValidFormatsOn = schema.validate({'someKey': 'http://example.com/dictionary/{term:1}/{term'});

    expect(isValidFormatsOn, isFalse);

    final isValidFormatsOff =
        schema.validate({'someKey': 'http://example.com/dictionary/{term:1}/{term'}, validateFormats: false);

    expect(isValidFormatsOff, isTrue);

    final errorsFormatsOn = schema.validateWithErrors({'someKey': 'http://example.com/dictionary/{term:1}/{term'});

    expect(errorsFormatsOn, isNotEmpty);

    final errorsFormatsOff = schema
        .validateWithResults({'someKey': 'http://example.com/dictionary/{term:1}/{term'}, validateFormats: false)
        .errors
        .isEmpty;

    expect(errorsFormatsOff, isEmpty);
  });
}
