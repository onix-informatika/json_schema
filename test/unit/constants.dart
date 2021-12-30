/// Formats introduced in Draft 4. 
/// Commented out lines are NOT skipped.
final List<String> skippedDraft4FormatTestFiles = const [
  // 'date-time.json',
  // 'email.json',
  // 'hostname.json',
  // 'ipv4.json',
  // 'ipv6.json',
  // 'uri.json',
];

/// Formats introduced in Draft 6. 
/// Commented out lines are NOT skipped.
final List<String> skippedDraft6FormatTestFiles = const [
  // 'json-pointer.json',
  // 'uri-reference.json',
  // 'uri-template.json',
];

/// Formats introduced in Draft 6. 
/// Commented out lines are NOT skipped.
final List<String> skippedDraft7FormatTestFiles  = const [
  // 'date.json',
  'idn-email.json',
  // 'idn-hostname.json',
  // 'iri-reference.json',
  // 'iri.json',
  // 'regex.json',
  // 'relative-json-pointer.json',
  // 'time.json',
];

/// Optional tests for Draft 7 (Not Optional later, 
/// so needed for 2019-09, 2020-12, etc):
final List<String> skippedOptionalDraft7TestFiles = const [
  'content.json',
];

/// Optional tests for all drafts.
final List<String> skippedOptionalTestFiles = const [
  // Optional for all Drafts:
  'bignum.json',
  'float-overflow.json',
];

/// These tests are skipped because they do not yet pass.
/// We strive to keep the length of this list at zero, 
/// but sometimes new tests are introducd that don't pass,
/// and we'd rather be up-to-date than have all tests pass.
final List<String> skippedNonWorkingTestFiles = const [
  // Not yet passing:
  'id.json',
  'unknownKeyword.json',
  // Not passing in the browser (Draft 4 Only)
  'zeroTerminatedFloats.json'
];

final List<String> commonSkippedTestFiles = []
  // Formats
  ..addAll(skippedDraft4FormatTestFiles)
  ..addAll(skippedDraft6FormatTestFiles)
  ..addAll(skippedDraft7FormatTestFiles)
  // Optional Tests
  ..addAll(skippedOptionalDraft7TestFiles)
  ..addAll(skippedOptionalTestFiles)
  // Non-passing Tests
  ..addAll(skippedNonWorkingTestFiles);

/// All Skipped tests below are OPTIONAL format tests. Implementations make a best effort to support these.
/// All Drafts: Dart Doesn't Support Leap-Seconds per: https://api.dart.dev/stable/2.15.1/dart-core/Duration/secondsPerMinute-constant.html
final List<String> skippedLeapSecondTests = const [
  // All Drafts:
  'validation of date-time strings : an invalid date-time past leap second, UTC', // date-time.json
  'validation of date-time strings : an invalid date-time with leap second on a wrong minute, UTC', // date-time.json
  'validation of date-time strings : an invalid date-time with leap second on a wrong hour, UTC', // date-time.json
  /// Draft 7 and later: 
  'validation of time strings : a valid time string with leap second, Zulu', // time.json
  'validation of time strings : valid leap second, zero time-offset', // time.json
  'validation of time strings : valid leap second, positive time-offset', // time.json
  'validation of time strings : valid leap second, large positive time-offset', // time.json
  'validation of time strings : valid leap second, negative time-offset', // time.json
  'validation of time strings : valid leap second, large negative time-offset', // time.json
];

/// All Skipped tests below are OPTIONAL format tests. Implementations make a best effort to support these.
/// We choose not to worry about these because we don't want our JSON Schema implementation to be LESS permissive than
/// the Dart language itself, as that might be confusing to consumers.
final List<String> skippedPermissiveDateTimeFormatTests = const [
  /// All Drafts:
  'validation of date-time strings : an invalid day in date-time string', // date-time.json
  'validation of date-time strings : an invalid offset in date-time string', // date-time.json
  'validation of date-time strings : case-insensitive T and Z', // date-time.json
  // Draft 7 and later (date format)
  'validation of date strings : a invalid date string with 29 days in February (normal)', // date.json
  'validation of date strings : a invalid date string with 30 days in February (leap)', // date.json
  'validation of date strings : a invalid date string with 31 days in April', // date.json
  'validation of date strings : a invalid date string with 31 days in June', // date.json
  'validation of date strings : a invalid date string with 31 days in September', // date.json
  'validation of date strings : a invalid date string with 31 days in November', // date.json
  'validation of date strings : invalid month-day combination', // date.json
  'validation of date strings : 2021 is not a leap year', // date.json
  // Draft 7 and later (time format)
  'validation of time strings : a valid time string with second fraction', // time.json
  'validation of time strings : a valid time string with precise second fraction', // time.json
  'validation of time strings : a valid time string with case-insensitive Z', // time.json
];

/// All Skipped tests below are OPTIONAL format tests. Implementations make a best effort to support these.
/// We choose not to worry about these because we don't want our JSON Schema implementation to be LESS permissive than
/// the Dart language itself, as that might be confusing to consumers.
final List<String> skippedIpv6FormatTests = const [
  'validation of IPv6 addresses : trailing whitespace is invalid', // ipv6.json
];

/// All Skipped tests below are OPTIONAL format tests. Implementations make a best effort to support these.
/// There is not currently a good relative json pointer implementation for Dart.
final List<String> skippedRelativeJsonPointerFormatTest = const [
  'validation of Relative JSON Pointers (RJP) : a valid upwards RJP', // relative-json-pointers.json
  'validation of Relative JSON Pointers (RJP) : a valid downwards RJP', // relative-json-pointers.json
  'validation of Relative JSON Pointers (RJP) : a valid up and then down RJP, with array index', // relative-json-pointers.json
  'validation of Relative JSON Pointers (RJP) : an invalid RJP that is a valid JSON Pointer', // relative-json-pointers.json
  'validation of Relative JSON Pointers (RJP) : a valid RJP taking the member or index name', // relative-json-pointers.json
];

/// All Skipped tests below are OPTIONAL format tests. Implementations make a best effort to support these.
/// There is not currently a good IDN Hostname format implementation for Dart.
final List<String> skppedIdnHostnameFormatTests = const [
  'validation of internationalized host names : a valid host name (example.test in Hangul)', // idn-hostname.json
  'validation of internationalized host names : valid Chinese Punycode', // idn-hostname.json
  'validation of internationalized host names : Exceptions that are PVALID, left-to-right chars', // idn-hostname.json
  'validation of internationalized host names : Exceptions that are PVALID, right-to-left chars', // idn-hostname.json
  'validation of internationalized host names : MIDDLE DOT with surrounding \'l\'s', // idn-hostname.json
  'validation of internationalized host names : Greek KERAIA followed by Greek', // idn-hostname.json
  'validation of internationalized host names : Hebrew GERESH preceded by Hebrew', // idn-hostname.json
  'validation of internationalized host names : Hebrew GERSHAYIM preceded by Hebrew', // idn-hostname.json
  'validation of internationalized host names : KATAKANA MIDDLE DOT with Hiragana', // idn-hostname.json
  'validation of internationalized host names : KATAKANA MIDDLE DOT with Katakana', // idn-hostname.json
  'validation of internationalized host names : KATAKANA MIDDLE DOT with Han', // idn-hostname.json
  'validation of internationalized host names : Arabic-Indic digits not mixed with Extended Arabic-Indic digits', // idn-hostname.json
  'validation of internationalized host names : Extended Arabic-Indic digits not mixed with Arabic-Indic digits', // idn-hostname.json
  'validation of internationalized host names : ZERO WIDTH JOINER preceded by Virama', // idn-hostname.json
  'validation of internationalized host names : ZERO WIDTH NON-JOINER preceded by Virama', // idn-hostname.json
  'validation of internationalized host names : ZERO WIDTH NON-JOINER not preceded by Virama but matches regexp', // idn-hostname.json
];

/// A list of tests to skip for all drafts.
/// Should match the portion of the test name printed after the JSON file name on test run.
final List<String> commonSkippedTests = []
  ..addAll(skippedLeapSecondTests)
  ..addAll(skippedPermissiveDateTimeFormatTests)
  ..addAll(skippedIpv6FormatTests)
  ..addAll(skippedRelativeJsonPointerFormatTest)
  ..addAll(skppedIdnHostnameFormatTests);
