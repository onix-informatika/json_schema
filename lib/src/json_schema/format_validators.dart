import 'package:json_schema/src/json_schema/constants.dart';
import 'package:json_schema/src/json_schema/format_validators/date_time_validator.dart';
import 'package:json_schema/src/json_schema/validation_context.dart';

import 'format_validators/date_validator.dart';
import 'format_validators/duration_validator.dart';
import 'format_validators/email_validator.dart';
import 'format_validators/hostname_validator.dart';
import 'format_validators/idn_email_validator.dart';
import 'format_validators/idn_hostname_validator.dart';
import 'format_validators/ipv4_validator.dart';
import 'format_validators/ipv6_validator.dart';
import 'format_validators/iri_validator.dart';
import 'format_validators/iri_reference_validator.dart';
import 'format_validators/json_pointer_validator.dart';
import 'format_validators/regex_validator.dart';
import 'format_validators/relative_json_pointer_validator.dart';
import 'format_validators/time_validator.dart';
import 'format_validators/uri_reference_validator.dart';
import 'format_validators/uri_template_validator.dart';
import 'format_validators/uri_validator.dart';
import 'format_validators/uuid_validator.dart';

Map<String, ValidationContext Function(ValidationContext context, SchemaVersion schemaVersion, String instanceData)>
    defaultFormatValidators = {
  'date': defaultDateValidator,
  'date-time': defaultDateTimeValidator,
  'duration': defaultDurationValidator,
  'email': defaultEmailValidator,
  'hostname': defaultHostnameValidator,
  'idn-email': defaultIdnEmailValidator,
  'idn-hostname': defaultIdnHostnameValidator,
  'ipv4': defaultIpv4Validator,
  'ipv6': defaultIpv6Validator,
  'iri': defaultIriValidator,
  'iri-reference': defaultIriReferenceValidator,
  'json-pointer': defaultJsonPointerValidator,
  'regex': defaultRegexValidator,
  'relative-json-pointer': defaultRelativeJsonPointerValidator,
  'time': defaultTimeValidator,
  'uri': defaultUriValidator,
  'uri-reference': defaultUriReferenceValidator,
  'uri-template': defaultUriTemplateValidator,
  'uuid': defaultUuidValidator,
};
