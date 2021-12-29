final List<String> commonSkippedTestFiles = const [
  /// Optional Formats: (Commented Lines are Working)
  // Draft 4
  // 'date-time.json',
  // 'email.json',
  // 'hostname.json',
  // 'ipv4.json',
  // 'ipv6.json',
  // 'uri.json',
  // Draft 6
  // 'json-pointer.json',
  // 'uri-reference.json',
  // 'uri-template.json',
  // Draft 7
  // 'date.json',
  'idn-email.json',
  // 'idn-hostname.json',
  // 'iri-reference.json',
  // 'iri.json',
  // 'regex.json',
  // 'relative-json-pointer.json',
  // 'time.json',

  // Optional:
  'bignum.json',
  'float-overflow.json',

  /// Optional in Draft 7 (Not Optional Later, so needed for 2019-09, 2020-12, etc):
  'content.json',

  // Not yet passing:
  'id.json',
  'unknownKeyword.json',

  // Not passing in the browser (Draft 4 Only)
  'zeroTerminatedFloats.json'
];

/// A list of tests to skip for all drafts.
/// Should match the portion of the test name printed after the JSON file name on test run.
final List<String> commonSkippedTests = const [
  /// All Drafts: Dart Doesn't Support Leap-Seconds per: https://api.dart.dev/stable/2.15.1/dart-core/Duration/secondsPerMinute-constant.html
  'validation of date-time strings : an invalid date-time past leap second, UTC', // date-time.json
  'validation of date-time strings : an invalid date-time with leap second on a wrong minute, UTC', // date-time.json
  'validation of date-time strings : an invalid date-time with leap second on a wrong hour, UTC', // date-time.json

  /// All Drafts: Dart Doesn't Support these edge cases.
  'validation of date-time strings : an invalid day in date-time string', // date-time.json
  'validation of date-time strings : an invalid offset in date-time string', // date-time.json
  'validation of date-time strings : case-insensitive T and Z', // date-time.json
  'validation of IPv6 addresses : trailing whitespace is invalid', // ipv6.json

  // Draft 7 and later: Dart Doesn't Support these edge cases.
  'validation of date strings : a invalid date string with 29 days in February (normal)', // date.json
  'validation of date strings : a invalid date string with 30 days in February (leap)', // date.json
  'validation of date strings : a invalid date string with 31 days in April', // date.json
  'validation of date strings : a invalid date string with 31 days in June', // date.json
  'validation of date strings : a invalid date string with 31 days in September', // date.json
  'validation of date strings : a invalid date string with 31 days in November', // date.json
  'validation of date strings : invalid month-day combination', // date.json
  'validation of date strings : 2021 is not a leap year', // date.json

  'validation of time strings : a valid time string with second fraction', // time.json
  'validation of time strings : a valid time string with precise second fraction', // time.json
  'validation of time strings : a valid time string with case-insensitive Z', // time.json

  'validation of Relative JSON Pointers (RJP) : a valid upwards RJP', // relative-json-pointers.json
  'validation of Relative JSON Pointers (RJP) : a valid downwards RJP', // relative-json-pointers.json
  'validation of Relative JSON Pointers (RJP) : a valid up and then down RJP, with array index', // relative-json-pointers.json
  'validation of Relative JSON Pointers (RJP) : an invalid RJP that is a valid JSON Pointer', // relative-json-pointers.json
  'validation of Relative JSON Pointers (RJP) : a valid RJP taking the member or index name', // relative-json-pointers.json

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

  /// Draft 7 and later: Dart Doesn't Support Leap-Seconds per: https://api.dart.dev/stable/2.15.1/dart-core/Duration/secondsPerMinute-constant.html
  'validation of time strings : a valid time string with leap second, Zulu', // time.json
  'validation of time strings : valid leap second, zero time-offset', // time.json
  'validation of time strings : valid leap second, positive time-offset', // time.json
  'validation of time strings : valid leap second, large positive time-offset', // time.json
  'validation of time strings : valid leap second, negative time-offset', // time.json
  'validation of time strings : valid leap second, large negative time-offset', // time.json
];
