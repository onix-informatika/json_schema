import 'package:json_schema/json_schema.dart';
import 'package:test/test.dart';

main() {
  test('Should respect configurable format validation', () {
    final schema = JsonSchema.create({
      'properties': {
        'someKey': {'format': 'uri-template'}
      }
    });

    final isValidFormatsOn =
        schema.validateWithResults({'someKey': 'http://example.com/dictionary/{term:1}/{term'}).errors.isEmpty;

    expect(isValidFormatsOn, isFalse);

    final isValidFormatsOff = schema
        .validateWithResults({'someKey': 'http://example.com/dictionary/{term:1}/{term'}, validateFormats: false)
        .errors
        .isEmpty;

    expect(isValidFormatsOff, isTrue);

    final errorsFormatsOn =
        schema.validateWithResults({'someKey': 'http://example.com/dictionary/{term:1}/{term'}).errors.isEmpty;

    expect(errorsFormatsOn, isFalse);

    final errorsFormatsOff = schema
        .validateWithResults({'someKey': 'http://example.com/dictionary/{term:1}/{term'}, validateFormats: false)
        .errors
        .isEmpty;

    expect(errorsFormatsOff, isTrue);
  });
}
