// Copyright 2013-2018 Workiva Inc.
//
// Licensed under the Boost Software License (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.boost.org/LICENSE_1_0.txt
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This software or document includes material copied from or derived
// from JSON-Schema-Test-Suite (https://github.com/json-schema-org/JSON-Schema-Test-Suite),
// Copyright (c) 2012 Julian Berman, which is licensed under the following terms:
//
//     Copyright (c) 2012 Julian Berman
//
//     Permission is hereby granted, free of charge, to any person obtaining a copy
//     of this software and associated documentation files (the "Software"), to deal
//     in the Software without restriction, including without limitation the rights
//     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//     copies of the Software, and to permit persons to whom the Software is
//     furnished to do so, subject to the following conditions:
//
//     The above copyright notice and this permission notice shall be included in
//     all copies or substantial portions of the Software.
//
//     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//     THE SOFTWARE.

import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:json_schema/src/json_schema/format_exceptions.dart';
import 'package:logging/logging.dart';

import 'package:json_schema/src/json_schema/constants.dart';
import 'package:json_schema/src/json_schema/json_schema.dart';
import 'package:json_schema/src/json_schema/schema_type.dart';
import 'package:json_schema/src/json_schema/global_platform_functions.dart' show defaultValidators;
import 'package:rfc_6901/rfc_6901.dart';

final Logger _logger = Logger('Validator');

class Instance {
  Instance(dynamic data, {String path = ''}) {
    this.data = data;
    this.path = path;
  }

  dynamic data;
  String path;

  @override
  toString() => data.toString();
}

class ValidationError {
  ValidationError._(this.instancePath, this.schemaPath, this.message);

  /// Path in the instance data to the key where this error occurred
  String instancePath;

  /// Path to the key in the schema containing the rule that produced this error
  String schemaPath;

  /// A human-readable message explaining why validation failed
  String message;

  @override
  toString() => '${instancePath.isEmpty ? '# (root)' : instancePath}: $message';
}

/// Initialized with schema, validates instances against it
class Validator {
  Validator(this._rootSchema);

  List<String> get errors => _errors.map((e) => e.toString()).toList();

  List<String> get warnings => _warnings.map((e) => e.toString()).toList();

  List<ValidationError> get errorObjects => _errors;

  List<ValidationError> get warningObjects => _warnings;

  bool _validateFormats;

  bool _treatWarningsAsErrors;

  /// The set of vocabularies (from the schema's metaschema) to be used for validation
  Set<Uri> _vocabulary;

  /// Validate the [instance] against the this validator's schema
  bool validate(dynamic instance,
      {bool reportMultipleErrors = false,
      bool parseJson = false,
      bool validateFormats,
      bool treatWarningsAsErrors = false}) {
    // Reference: https://json-schema.org/draft/2019-09/release-notes.html#format-vocabulary
    // By default, formats are validated on a best-effort basis from draft4 through draft7.
    // Starting with Draft 2019-09, formats shouldn't be validated by default.
    _validateFormats = validateFormats ?? _rootSchema.schemaVersion <= SchemaVersion.draft7;
    _treatWarningsAsErrors = treatWarningsAsErrors;

    dynamic data = instance;
    if (parseJson && instance is String) {
      try {
        data = json.decode(instance);
      } catch (e) {
        throw ArgumentError('JSON instance provided to validate is not valid JSON.');
      }
    }

    _reportMultipleErrors = reportMultipleErrors;
    // Initialize and validate the vocabulary to be used for validation
    _vocabulary = getVocabulary(_rootSchema);
    if (!_reportMultipleErrors) {
      try {
        _validate(_rootSchema, data);
        return true;
      } on FormatException {
        return false;
      } catch (e) {
        _logger.shout('Unexpected Exception: $e');
        return false;
      }
    }

    _validate(_rootSchema, data);
    return _errors.isEmpty && (!treatWarningsAsErrors || _warnings.isEmpty);
  }

  Set<Uri> getVocabulary(JsonSchema s) {
    if (s.schemaVersion < SchemaVersion.draft2019_09) {
      // For simplicity's sake, we just use all supported vocabularies for drafts older than 2019.
      return SupportedVocabularies.ALL;
    } else {
      final vocab = s.metaschemaVocabulary();
      vocab.forEach((uri, isRequired) {
        if (!SupportedVocabularies.ALL.contains(uri)) {
          if (isRequired) {
            throw ArgumentError("unsupported vocabulary required for validation", "$uri");
          } else {
            _warn('unsupported optional vocabulary in use: $uri', '', r'$schema');
          }
        }
      });
      return Set.of(vocab.keys).intersection(SupportedVocabularies.ALL);
    }
  }

  static bool _typeMatch(SchemaType type, JsonSchema schema, dynamic instance) {
    if (type == SchemaType.object) {
      return instance is Map;
    } else if (type == SchemaType.string) {
      return instance is String;
    } else if (type == SchemaType.integer) {
      return instance is int ||
          (schema.schemaVersion >= SchemaVersion.draft6 && instance is num && instance.remainder(1) == 0);
    } else if (type == SchemaType.number) {
      return instance is num;
    } else if (type == SchemaType.array) {
      return instance is List;
    } else if (type == SchemaType.boolean) {
      return instance is bool;
    } else if (type == SchemaType.nullValue) {
      return instance == null;
    }
    return false;
  }

  void _numberValidation(JsonSchema schema, Instance instance) {
    final num n = instance.data;

    final maximum = schema.maximum;
    final minimum = schema.minimum;
    final exclusiveMaximum = schema.exclusiveMaximum;
    final exclusiveMinimum = schema.exclusiveMinimum;

    final warnOrErr = _errFuncForVocabulary(SupportedVocabularies.VALIDATION);

    if (exclusiveMaximum != null) {
      if (n >= exclusiveMaximum) {
        warnOrErr('exclusiveMaximum exceeded ($n >= $exclusiveMaximum)', instance.path, schema.path);
      }
    } else if (maximum != null) {
      if (n > maximum) {
        warnOrErr('maximum exceeded ($n > $maximum)', instance.path, schema.path);
      }
    }

    if (exclusiveMinimum != null) {
      if (n <= exclusiveMinimum) {
        warnOrErr('exclusiveMinimum violated ($n <= $exclusiveMinimum)', instance.path, schema.path);
      }
    } else if (minimum != null) {
      if (n < minimum) {
        warnOrErr('minimum violated ($n < $minimum)', instance.path, schema.path);
      }
    }

    final multipleOf = schema.multipleOf;
    if (multipleOf != null) {
      if (multipleOf is int && n is int) {
        if (0 != n % multipleOf) {
          warnOrErr('multipleOf violated ($n % $multipleOf)', instance.path, schema.path);
        }
      } else {
        final double result = n / multipleOf;
        if (result == double.infinity) {
          warnOrErr('multipleOf violated ($n % $multipleOf)', instance.path, schema.path);
        } else if (result.truncate() != result) {
          warnOrErr('multipleOf violated ($n % $multipleOf)', instance.path, schema.path);
        }
      }
    }
  }

  void _typeValidation(JsonSchema schema, dynamic instance) {
    final typeList = schema.typeList;
    if (typeList != null && typeList.isNotEmpty) {
      if (!typeList.any((type) => _typeMatch(type, schema, instance.data))) {
        _errFuncForVocabulary(SupportedVocabularies.VALIDATION)(
            'type: wanted ${typeList} got $instance', instance.path, schema.path);
      }
    }
  }

  void _constValidation(JsonSchema schema, dynamic instance) {
    if (schema.hasConst && !DeepCollectionEquality().equals(instance.data, schema.constValue)) {
      _errFuncForVocabulary(SupportedVocabularies.VALIDATION)('const violated ${instance}', instance.path, schema.path);
    }
  }

  void _enumValidation(JsonSchema schema, dynamic instance) {
    final enumValues = schema.enumValues;
    if (enumValues.isNotEmpty) {
      try {
        enumValues.singleWhere((v) => DeepCollectionEquality().equals(instance.data, v));
      } on StateError {
        _errFuncForVocabulary(SupportedVocabularies.VALIDATION)(
            'enum violated ${instance}', instance.path, schema.path);
      }
    }
  }

  void _validateDeprecated(JsonSchema schema, dynamic instance) {
    if (schema.deprecated == true) {
      _warn('deprecated ${instance}', instance.path, schema.path);
    }
  }

  void _stringValidation(JsonSchema schema, Instance instance) {
    final warnOrErr = _errFuncForVocabulary(SupportedVocabularies.VALIDATION);
    final actual = instance.data.runes.length;
    final minLength = schema.minLength;
    final maxLength = schema.maxLength;
    if (maxLength is int && actual > maxLength) {
      warnOrErr('maxLength exceeded ($instance vs $maxLength)', instance.path, schema.path);
    } else if (minLength is int && actual < minLength) {
      warnOrErr('minLength violated ($instance vs $minLength)', instance.path, schema.path);
    }
    final pattern = schema.pattern;
    if (pattern != null && !pattern.hasMatch(instance.data)) {
      warnOrErr('pattern violated ($instance vs $pattern)', instance.path, schema.path);
    }
  }

  void _itemsValidation(JsonSchema schema, Instance instance) {
    final int actual = instance.data.length;

    final singleSchema = schema.items;
    if (singleSchema != null) {
      instance.data.asMap().forEach((index, item) {
        final itemInstance = Instance(item, path: '${instance.path}/$index');
        _validate(singleSchema, itemInstance);
      });
    } else {
      final items = schema.itemsList;

      if (items != null && _vocabulary.contains(SupportedVocabularies.APPLICATOR)) {
        final expected = items.length;
        final end = min(expected, actual);
        for (int i = 0; i < end; i++) {
          assert(items[i] != null);
          final itemInstance = Instance(instance.data[i], path: '${instance.path}/$i');
          _validate(items[i], itemInstance);
        }
        if (schema.additionalItemsSchema != null) {
          for (int i = end; i < actual; i++) {
            final itemInstance = Instance(instance.data[i], path: '${instance.path}/$i');
            _validate(schema.additionalItemsSchema, itemInstance);
          }
        } else if (schema.additionalItemsBool != null) {
          if (!schema.additionalItemsBool && actual > end) {
            _err('additionalItems false', instance.path, schema.path + '/additionalItems');
          }
        }
      }
    }

    final warnOrErr = _errFuncForVocabulary(SupportedVocabularies.VALIDATION);
    final maxItems = schema.maxItems;
    final minItems = schema.minItems;
    if (maxItems is int && actual > maxItems) {
      warnOrErr('maxItems exceeded ($actual vs $maxItems)', instance.path, schema.path);
    } else if (schema.minItems is int && actual < schema.minItems) {
      warnOrErr('minItems violated ($actual vs $minItems)', instance.path, schema.path);
    }

    if (schema.uniqueItems) {
      final end = instance.data.length;
      final penultimate = end - 1;
      for (int i = 0; i < penultimate; i++) {
        for (int j = i + 1; j < end; j++) {
          if (DeepCollectionEquality().equals(instance.data[i], instance.data[j])) {
            warnOrErr('uniqueItems violated: $instance [$i]==[$j]', instance.path, schema.path);
          }
        }
      }
    }

    if (schema.contains != null) {
      final maxContains = schema.maxContains;
      final minContains = schema.minContains;
      final containsItems = instance.data.where((item) => Validator(schema.contains).validate(item)).toList();
      if (minContains is int && containsItems.length < minContains) {
        warnOrErr('minContains violated: $instance', instance.path, schema.path);
      }
      if (maxContains is int && containsItems.length > maxContains) {
        warnOrErr('maxContains violated: $instance', instance.path, schema.path);
      }
      if (containsItems.length == 0 && !(minContains is int && minContains == 0)) {
        warnOrErr('contains violated: $instance', instance.path, schema.path);
      }
    }
  }

  void _validateAllOf(JsonSchema schema, Instance instance) {
    final warnOrErr = _errFuncForVocabulary(SupportedVocabularies.APPLICATOR);
    if (!schema.allOf.every((s) => Validator(s).validate(instance))) {
      warnOrErr('${schema.path}: allOf violated ${instance}', instance.path, schema.path + '/allOf');
    }
  }

  void _validateAnyOf(JsonSchema schema, Instance instance) {
    final warnOrErr = _errFuncForVocabulary(SupportedVocabularies.APPLICATOR);
    if (!schema.anyOf.any((s) => Validator(s).validate(instance))) {
      warnOrErr(
          '${schema.path}/anyOf: anyOf violated ($instance, ${schema.anyOf})', instance.path, schema.path + '/anyOf');
    }
  }

  void _validateOneOf(JsonSchema schema, Instance instance) {
    try {
      schema.oneOf.singleWhere((s) => Validator(s).validate(instance));
    } on StateError catch (notOneOf) {
      _errFuncForVocabulary(SupportedVocabularies.APPLICATOR)(
          '${schema.path}/oneOf: violated ${notOneOf.message}', instance.path, schema.path + '/oneOf');
    }
  }

  void _validateNot(JsonSchema schema, Instance instance) {
    final warnOrErr = _errFuncForVocabulary(SupportedVocabularies.APPLICATOR);
    if (Validator(schema.notSchema).validate(instance)) {
      warnOrErr('${schema.notSchema.path}: not violated', instance.path, schema.notSchema.path);
    }
  }

  void _validateFormat(JsonSchema schema, Instance instance) {
    if (!_validateFormats) return;
    // Non-strings in formats should be ignored.
    if (instance.data is! String) return;

    final warnOrErr = _errFuncForVocabulary(SupportedVocabularies.FORMAT);
    switch (schema.format) {
      case 'date-time':
        try {
          DateTime.parse(instance.data);
        } catch (e) {
          warnOrErr('"date-time" format not accepted $instance', instance.path, schema.path);
        }
        break;
      case 'time':
        // regex is an allowed format in draft3, out in draft4/6, back in draft7.
        // Since we don't support draft3, just draft7 is needed here.
        if (SchemaVersion.draft7 != schema.schemaVersion) return;
        if (JsonSchemaValidationRegexes.fullTime.firstMatch(instance.data) == null) {
          warnOrErr('"time" format not accepted $instance', instance.path, schema.path);
        }
        break;
      case 'date':
        // regex is an allowed format in draft3, out in draft4/6, back in draft7.
        // Since we don't support draft3, just draft7 is needed here.
        if (SchemaVersion.draft7 != schema.schemaVersion) return;
        if (JsonSchemaValidationRegexes.fullDate.firstMatch(instance.data) == null) {
          warnOrErr('"date" format not accepted $instance', instance.path, schema.path);
        }
        break;
      case 'uri':
        final isValid = defaultValidators.uriValidator ?? (_) => false;

        if (!isValid(instance.data)) {
          warnOrErr('"uri" format not accepted $instance', instance.path, schema.path);
        }
        break;
      case 'iri':
        if (SchemaVersion.draft7 != schema.schemaVersion) return;
        // Dart's URI class supports parsing IRIs, so we can use the same validator
        final isValid = defaultValidators.uriValidator ?? (_) => false;

        if (!isValid(instance.data)) {
          warnOrErr('"iri" format not accepted $instance', instance.path, schema.path);
        }
        break;
      case 'iri-reference':
        if (SchemaVersion.draft7 != schema.schemaVersion) return;

        // Dart's URI class supports parsing IRIs, so we can use the same validator
        final isValid = defaultValidators.uriReferenceValidator ?? (_) => false;

        if (!isValid(instance.data)) {
          warnOrErr('"iri-reference" format not accepted $instance', instance.path, schema.path);
        }
        break;
      case 'uri-reference':
        if (![SchemaVersion.draft6, SchemaVersion.draft7].contains(schema.schemaVersion)) return;
        final isValid = defaultValidators.uriReferenceValidator ?? (_) => false;

        if (!isValid(instance.data)) {
          warnOrErr('"uri-reference" format not accepted $instance', instance.path, schema.path);
        }
        break;
      case 'uri-template':
        if (![SchemaVersion.draft6, SchemaVersion.draft7].contains(schema.schemaVersion)) return;
        final isValid = defaultValidators.uriTemplateValidator ?? (_) => false;

        if (!isValid(instance.data)) {
          warnOrErr('"uri-template" format not accepted $instance', instance.path, schema.path);
        }
        break;
      case 'email':
        final isValid = defaultValidators.emailValidator ?? (_) => false;

        if (!isValid(instance.data)) {
          warnOrErr('"email" format not accepted $instance', instance.path, schema.path);
        }
        break;
      case 'idn-email':
        // No maintained dart packages exist to validate RFC6531,
        // and it's too complex for a regex, so best effort is to pass for now.
        break;
      case 'ipv4':
        if (JsonSchemaValidationRegexes.ipv4.firstMatch(instance.data) == null) {
          warnOrErr('"ipv4" format not accepted $instance', instance.path, schema.path);
        }
        break;
      case 'ipv6':
        try {
          Uri.parseIPv6Address(instance.data);
        } on FormatException catch (_) {
          warnOrErr('"ipv6" format not accepted $instance', instance.path, schema.path);
        }
        break;
      case 'hostname':
        final regexp = schema.schemaVersion.compareTo(SchemaVersion.draft2019_09) < 0
            ? JsonSchemaValidationRegexes.hostname
            // Updated in Draft 2019-09
            : JsonSchemaValidationRegexes.hostnameDraft2019;

        if (regexp.firstMatch(instance.data) == null) {
          warnOrErr('"hostname" format not accepted $instance', instance.path, schema.path);
        }
        break;
      case 'idn-hostname':
        // Introduced in Draft 7
        if (schema.schemaVersion.compareTo(SchemaVersion.draft7) < 0) return;

        final regexp = schema.schemaVersion.compareTo(SchemaVersion.draft2019_09) < 0
            ? JsonSchemaValidationRegexes.idnHostname
            // Updated in Draft 2019-09
            : JsonSchemaValidationRegexes.idnHostnameDraft2019;

        if (regexp.firstMatch(instance.data) == null) {
          warnOrErr('"idn-hostname" format not accepted $instance', instance.path, schema.path);
        }
        break;
      case 'json-pointer':
        if (![SchemaVersion.draft6, SchemaVersion.draft7].contains(schema.schemaVersion)) return;
        try {
          JsonPointer(instance.data);
        } on FormatException catch (_) {
          warnOrErr('"json-pointer" format not accepted $instance', instance.path, schema.path);
        }
        break;
      case 'relative-json-pointer':
        if (SchemaVersion.draft7 != schema.schemaVersion) return;
        if (JsonSchemaValidationRegexes.relativeJsonPointer.firstMatch(instance.data) == null) {
          warnOrErr('"relative-json-pointer" format not accepted $instance', instance.path, schema.path);
        }
        break;
      case 'regex':
        // regex is an allowed format in draft3, out in draft4/6, back in draft7.
        // Since we don't support draft3, just draft7 is needed here.
        if (SchemaVersion.draft7 != schema.schemaVersion) return;
        try {
          RegExp(instance.data, unicode: true);
        } catch (e) {
          warnOrErr('"regex" format not accepted $instance', instance.path, schema.path);
        }
        break;
      case 'duration':
        if (SchemaVersion.draft2019_09.compareTo(schema.schemaVersion) > 0) return;
        if (JsonSchemaValidationRegexes.duration.firstMatch(instance.data) == null) {
          warnOrErr('"duration" format not accepted $instance', instance.path, schema.path);
        }
        break;
      case 'uuid':
        if (SchemaVersion.draft2019_09.compareTo(schema.schemaVersion) > 0) return;
        if (JsonSchemaValidationRegexes.uuid.firstMatch(instance.data) == null) {
          warnOrErr('"uuid" format not accepted $instance', instance.path, schema.path);
        }
        break;
      default:
        // Don't attempt to validate unknown formats.
        break;
    }
  }

  void _objectPropertyValidation(JsonSchema schema, Instance instance) {
    if (!_vocabulary.contains(SupportedVocabularies.APPLICATOR)) return;
    final propMustValidate = schema.additionalPropertiesBool != null && !schema.additionalPropertiesBool;

    instance.data.forEach((k, v) {
      // Validate property names against the provided schema, if any.
      if (schema.propertyNamesSchema != null) {
        _validate(schema.propertyNamesSchema, k);
      }

      final newInstance = Instance(v, path: '${instance.path}/$k');

      bool propCovered = false;
      final JsonSchema propSchema = schema.properties[k];
      if (propSchema != null) {
        assert(propSchema != null);
        _validate(propSchema, newInstance);
        propCovered = true;
      }

      schema.patternProperties.forEach((regex, patternSchema) {
        if (regex.hasMatch(k)) {
          assert(patternSchema != null);
          _validate(patternSchema, newInstance);
          propCovered = true;
        }
      });

      if (!propCovered) {
        if (schema.additionalPropertiesSchema != null) {
          _validate(schema.additionalPropertiesSchema, newInstance);
        } else if (propMustValidate) {
          _err('unallowed additional property $k', instance.path, schema.path + '/additionalProperties');
        }
      }
    });
  }

  void _propertyDependenciesValidation(JsonSchema schema, Instance instance) {
    final warnOrErr = _errFuncForVocabulary(SupportedVocabularies.APPLICATOR);
    schema.propertyDependencies.forEach((k, dependencies) {
      if (instance.data.containsKey(k)) {
        if (!dependencies.every((prop) => instance.data.containsKey(prop))) {
          warnOrErr('prop $k => $dependencies required', instance.path, schema.path + '/dependencies');
        }
      }
    });
  }

  void _schemaDependenciesValidation(JsonSchema schema, Instance instance) {
    final warnOrErr = _errFuncForVocabulary(SupportedVocabularies.APPLICATOR);
    schema.schemaDependencies.forEach((k, otherSchema) {
      if (instance.data.containsKey(k)) {
        if (!Validator(otherSchema).validate(instance)) {
          warnOrErr('prop $k violated schema dependency', instance.path, otherSchema.path);
        }
      }
    });
  }

  void _objectValidation(JsonSchema schema, Instance instance) {
    final warnOrErr = _errFuncForVocabulary(SupportedVocabularies.VALIDATION);
    // Min / Max Props
    final numProps = instance.data.length;
    final minProps = schema.minProperties;
    final maxProps = schema.maxProperties;
    if (numProps < minProps) {
      warnOrErr('minProperties violated (${numProps} < ${minProps})', instance.path, schema.path);
    } else if (maxProps != null && numProps > maxProps) {
      warnOrErr('maxProperties violated (${numProps} > ${maxProps})', instance.path, schema.path);
    }

    // Required Properties
    if (schema.requiredProperties != null) {
      schema.requiredProperties.forEach((prop) {
        if (!instance.data.containsKey(prop)) {
          // One error for the root object that contains the missing property.
          warnOrErr('required prop missing: ${prop} from $instance', instance.path, schema.path + '/required');
          // Another error for the property on the root object. (Allows consumers to identify errors for individual fields)
          warnOrErr(
              'required prop missing: ${prop} from $instance', '${instance.path}/${prop}', schema.path + '/required');
        }
      });
    }

    _objectPropertyValidation(schema, instance);

    if (schema.propertyDependencies != null) _propertyDependenciesValidation(schema, instance);

    if (schema.schemaDependencies != null) _schemaDependenciesValidation(schema, instance);
  }

  void _validate(JsonSchema schema, dynamic instance) {
    if (instance is! Instance) {
      instance = Instance(instance);
    }

    /// If the [JsonSchema] being validated is a ref, pull the ref
    /// from the [refMap] instead.
    while (schema.ref != null || schema.recursiveRef != null) {
      var nextSchema = schema.resolvePath(schema.ref ?? schema.recursiveRef);
      if (schema.recursiveRef != null && nextSchema.recursiveAnchor == true) {
        schema = nextSchema.furthestRecursiveAnchorParent();
      } else if (schema.schemaVersion == SchemaVersion.draft2019_09 &&
          schema.schemaMap.length > 1 &&
          nextSchema.schemaBool == null) {
        schema.mixinForRef(nextSchema);
      } else {
        schema = nextSchema;
      }
    }

    /// If the [JsonSchema] is a bool, always return this value.
    if (schema.schemaBool != null) {
      if (schema.schemaBool == false) {
        _err('schema is a boolean == false, this schema will never validate. Instance: $instance', instance.path,
            schema.path);
      }
      return;
    }

    _ifThenElseValidation(schema, instance);
    _typeValidation(schema, instance);
    _constValidation(schema, instance);
    _enumValidation(schema, instance);
    if (instance.data is List) _itemsValidation(schema, instance);
    if (instance.data is String) _stringValidation(schema, instance);
    if (instance.data is num) _numberValidation(schema, instance);
    if (schema.allOf.isNotEmpty) _validateAllOf(schema, instance);
    if (schema.anyOf.isNotEmpty) _validateAnyOf(schema, instance);
    if (schema.oneOf.isNotEmpty) _validateOneOf(schema, instance);
    if (schema.notSchema != null) _validateNot(schema, instance);
    if (schema.format != null) _validateFormat(schema, instance);
    if (instance.data is Map) _objectValidation(schema, instance);
    if (schema.deprecated == true) _validateDeprecated(schema, instance);
  }

  bool _ifThenElseValidation(JsonSchema schema, Instance instance) {
    if (schema.ifSchema != null) {
      final warnOrErr = _errFuncForVocabulary(SupportedVocabularies.APPLICATOR);

      // Bail out early if no 'then' or 'else' schemas exist.
      if (schema.thenSchema == null && schema.elseSchema == null) return true;

      if (schema.ifSchema.validate(instance)) {
        // Bail out early if no "then" is specified.
        if (schema.thenSchema == null) return true;
        if (!Validator(schema.thenSchema).validate(instance)) {
          warnOrErr('${schema.path}/then: then violated ($instance, ${schema.thenSchema})', instance.path,
              schema.path + '/then');
        }
      } else {
        // Bail out early if no "else" is specified.
        if (schema.elseSchema == null) return true;
        if (!Validator(schema.elseSchema).validate(instance)) {
          warnOrErr('${schema.path}/else: else violated ($instance, ${schema.elseSchema})', instance.path,
              schema.path + '/else');
        }
      }
      // Return early since we recursively call _validate in these cases.
      return true;
    }
    return false;
  }

  void _err(String msg, String instancePath, String schemaPath) {
    schemaPath = schemaPath.replaceFirst('#', '');
    _errors.add(ValidationError._(instancePath, schemaPath, msg));
    if (!_reportMultipleErrors) throw FormatException(msg);
  }

  void _warn(String msg, String instancePath, String schemaPath) {
    schemaPath = schemaPath.replaceFirst('#', '');
    _warnings.add(ValidationError._(instancePath, schemaPath, msg));
    if (!_reportMultipleErrors && _treatWarningsAsErrors) throw FormatException(msg);
  }

  Function(String, String, String) _errFuncForVocabulary(Uri v) {
    return _vocabulary.contains(v)
        ? _err
        : (String msg, String instancePath, String schemaPath) =>
            _warn('ignoring vocabulary $v: $msg', instancePath, schemaPath);
  }

  JsonSchema _rootSchema;
  List<ValidationError> _errors = [];
  List<ValidationError> _warnings = [];
  bool _reportMultipleErrors;
}
