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

// @TestOn('browser')

import 'dart:convert';
// import 'dart:io';
import 'package:json_schema/json_schema.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../constants.dart';
import '../specification_remotes.dart';
import '../specification_tests.dart';

void main() {
  // // Draft 4 Tests
  // final Directory testSuiteFolderV4 = Directory('./test/JSON-Schema-Test-Suite/tests/draft4');
  // final Directory optionalsV4 = Directory(path.joinAll([testSuiteFolderV4.path, 'optional']));
  // final allDraft4 = testSuiteFolderV4.listSync()..addAll(optionalsV4.listSync());

  // // Draft 6 Tests
  // final Directory testSuiteFolderV6 = Directory('./test/JSON-Schema-Test-Suite/tests/draft6');
  // final Directory optionalsV6 = Directory(path.joinAll([testSuiteFolderV6.path, 'optional']));
  // final allDraft6 = testSuiteFolderV6.listSync()..addAll(optionalsV6.listSync());

  // // Draft 7 Tests
  // final Directory testSuiteFolderV7 = Directory('./test/JSON-Schema-Test-Suite/tests/draft7');
  // final Directory optionalsV7 = Directory(path.joinAll([testSuiteFolderV7.path, 'optional']));
  // final allDraft7 = testSuiteFolderV7.listSync()..addAll(optionalsV7.listSync());

  final allDraft4 =
      specificationTests.entries.where((MapEntry<String, String> entry) => entry.key.startsWith('/draft4'));
  final allDraft6 =
      specificationTests.entries.where((MapEntry<String, String> entry) => entry.key.startsWith('/draft6'));
  final allDraft7 =
      specificationTests.entries.where((MapEntry<String, String> entry) => entry.key.startsWith('/draft7'));

  final runAllTestsForDraftX = (SchemaVersion schemaVersion, Iterable<MapEntry<String, String>> allTests,
      List<String> skipFiles, List<String> skipTests,
      {bool isSync = false, RefProvider refProvider}) {
    String shortSchemaVersion = schemaVersion.toString();
    if (schemaVersion == SchemaVersion.draft4) {
      shortSchemaVersion = 'draft4';
    } else if (schemaVersion == SchemaVersion.draft6) {
      shortSchemaVersion = 'draft6';
    } else if (schemaVersion == SchemaVersion.draft7) {
      shortSchemaVersion = 'draft7';
    }

    allTests.forEach((testEntry) {
      if (testEntry is MapEntry) {
        final checkResult = (List<ValidationError> validationResults, bool expectedResult) {
          if (validationResults.isEmpty != expectedResult && expectedResult == true) {
            validationResults.forEach((error) {
              print(error);
            });
          }
          expect(validationResults.isEmpty, expectedResult);
        };

        group('Validations ($shortSchemaVersion) ${path.basename(testEntry.key)}', () {
          // Skip these for now - reason shown.
          if (skipFiles.contains(path.basename(testEntry.key))) return;

          final List tests = json.decode(testEntry.value);
          tests.forEach((testEntry) {
            final schemaData = testEntry['schema'];
            final description = testEntry['description'];
            final List validationTests = testEntry['tests'];

            validationTests.forEach((validationTest) {
              final String validationDescription = validationTest['description'];
              final String testName = '${description} : ${validationDescription}';

              // Individual test cases to skip - reason listed in comments.
              if (skipTests.contains(testName)) return;

              test(testName, () {
                final instance = validationTest['data'];
                List<ValidationError> validationResults;
                final bool expectedResult = validationTest['valid'];

                if (isSync) {
                  final schema = JsonSchema.create(
                    schemaData,
                    schemaVersion: schemaVersion,
                    refProvider: refProvider,
                  );
                  validationResults = schema.validateWithErrors(instance);
                  expect(validationResults.isEmpty, expectedResult);
                } else {
                  final checkResultAsync = expectAsync2(checkResult);
                  JsonSchema.createAsync(schemaData, schemaVersion: schemaVersion, refProvider: refProvider)
                      .then((schema) {
                    validationResults = schema.validateWithErrors(instance);
                    checkResultAsync(validationResults, expectedResult);
                  });
                }
              });
            });
          });
        });
      }
    });
  };

  // Mock Ref Provider for refRemote tests. Emulates what createFromUrl would return.
  final RefProvider syncRefProvider = RefProvider.sync((String ref) {
    return json.decode(specificationRemotes[ref]);
  });

  // ignore: deprecated_member_use_from_same_package
  final RefProvider deprecatedSyncRefSchemaProvider = RefProvider.syncSchema((String ref) {
    final schemaDef = syncRefProvider.provide(ref);
    if (schemaDef != null) {
      return JsonSchema.create(schemaDef);
    }

    return null;
  });

  final RefProvider asyncRefProvider = RefProvider.async((String ref) async {
    // Mock a delayed response.
    await Future.delayed(Duration(microseconds: 1));
    return syncRefProvider.provide(ref);
  });

  // ignore: deprecated_member_use_from_same_package
  final RefProvider deprecatedAsyncRefSchemaProvider = RefProvider.asyncSchema((String ref) async {
    // Mock a delayed response.
    await Future.delayed(Duration(microseconds: 1));
    return deprecatedSyncRefSchemaProvider.provide(ref);
  });

  // Run all tests asynchronously with no ref provider.
  runAllTestsForDraftX(
    SchemaVersion.draft4,
    allDraft4,
    commonSkippedTestFiles,
    commonSkippedTests,
  );
  runAllTestsForDraftX(
    SchemaVersion.draft6,
    allDraft6,
    commonSkippedTestFiles,
    commonSkippedTests,
  );
  runAllTestsForDraftX(
    SchemaVersion.draft7,
    allDraft7,
    commonSkippedTestFiles,
    commonSkippedTests,
  );

  // Run all tests synchronously with a sync ref provider.
  runAllTestsForDraftX(
    SchemaVersion.draft4,
    allDraft4,
    commonSkippedTestFiles,
    commonSkippedTests,
    isSync: true,
    refProvider: deprecatedSyncRefSchemaProvider,
  );
  runAllTestsForDraftX(
    SchemaVersion.draft6,
    allDraft6,
    commonSkippedTestFiles,
    commonSkippedTests,
    isSync: true,
    refProvider: deprecatedSyncRefSchemaProvider,
  );
  runAllTestsForDraftX(
    SchemaVersion.draft7,
    allDraft7,
    commonSkippedTestFiles,
    commonSkippedTests,
    isSync: true,
    refProvider: deprecatedSyncRefSchemaProvider,
  );

  // Run all tests synchronously with a sync json provider.
  runAllTestsForDraftX(
    SchemaVersion.draft4,
    allDraft4,
    commonSkippedTestFiles,
    commonSkippedTests,
    isSync: true,
    refProvider: syncRefProvider,
  );
  runAllTestsForDraftX(
    SchemaVersion.draft6,
    allDraft6,
    commonSkippedTestFiles,
    commonSkippedTests,
    isSync: true,
    refProvider: syncRefProvider,
  );
  runAllTestsForDraftX(
    SchemaVersion.draft7,
    allDraft6,
    commonSkippedTestFiles,
    commonSkippedTests,
    isSync: true,
    refProvider: syncRefProvider,
  );

  // Run all tests asynchronously with an async ref provider.
  runAllTestsForDraftX(
    SchemaVersion.draft4,
    allDraft4,
    commonSkippedTestFiles,
    commonSkippedTests,
    refProvider: deprecatedAsyncRefSchemaProvider,
  );
  runAllTestsForDraftX(
    SchemaVersion.draft6,
    allDraft6,
    commonSkippedTestFiles,
    commonSkippedTests,
    refProvider: deprecatedAsyncRefSchemaProvider,
  );
  runAllTestsForDraftX(
    SchemaVersion.draft7,
    allDraft6,
    commonSkippedTestFiles,
    commonSkippedTests,
    refProvider: deprecatedAsyncRefSchemaProvider,
  );

  // Run all tests asynchronously with an async json provider.
  runAllTestsForDraftX(
    SchemaVersion.draft4,
    allDraft4,
    commonSkippedTestFiles,
    commonSkippedTests,
    refProvider: asyncRefProvider,
  );
  runAllTestsForDraftX(
    SchemaVersion.draft6,
    allDraft6,
    commonSkippedTestFiles,
    commonSkippedTests,
    refProvider: asyncRefProvider,
  );
  runAllTestsForDraftX(
    SchemaVersion.draft7,
    allDraft6,
    commonSkippedTestFiles,
    commonSkippedTests,
    refProvider: asyncRefProvider,
  );

  group('Nested \$refs in root schema', () {
    test('properties', () async {
      final barSchema = await JsonSchema.createAsync({
        "properties": {
          "foo": {"\$ref": "http://localhost:1234/integer.json#"},
          "bar": {"\$ref": "http://localhost:4321/string.json#"}
        },
        "required": ["foo", "bar"]
      });

      final isValid = barSchema.validate({"foo": 2, "bar": "test"});

      final isInvalid = barSchema.validate({"foo": 2, "bar": 4});

      expect(isValid, isTrue);
      expect(isInvalid, isFalse);
    });

    test('items', () async {
      final schema = await JsonSchema.createAsync({
        "items": {"\$ref": "http://localhost:1234/integer.json"}
      });

      final isValid = schema.validate([1, 2, 3, 4]);
      final isInvalid = schema.validate([1, 2, 3, '4']);

      expect(isValid, isTrue);
      expect(isInvalid, isFalse);
    });

    test('not / anyOf', () async {
      final schema = await JsonSchema.createAsync({
        "items": {
          "not": {
            "anyOf": [
              {"\$ref": "http://localhost:1234/integer.json#"},
              {"\$ref": "http://localhost:4321/string.json#"},
            ]
          }
        }
      });

      final isValid = schema.validate([3.4]);
      final isInvalid = schema.validate(['test']);

      expect(isValid, isTrue);
      expect(isInvalid, isFalse);
    });
  });

  test('Recursive refs from a remote schema should be supported with a json provider', () async {
    final RefProvider syncRefJsonProvider = RefProvider.sync((String ref) {
      switch (ref) {
        case 'http://localhost:1234/tree.json':
          return {
            "\$id": "http://localhost:1234/tree.json",
            "description": "tree of nodes",
            "type": "object",
            "properties": {
              "meta": {"type": "string"},
              "nodes": {
                "type": "array",
                "items": {"\$ref": "node.json"}
              }
            },
            "required": ["meta", "nodes"]
          };
        case 'http://localhost:1234/node.json':
          return {
            "\$id": "http://localhost:1234/node.json",
            "description": "nodes",
            "type": "object",
            "properties": {
              "value": {"type": "number"},
              "subtree": {"\$ref": "tree.json"}
            },
            "required": ["value"]
          };
        default:
          return null;
      }
    });

    final schema = JsonSchema.create(
      syncRefJsonProvider.provide('http://localhost:1234/tree.json'),
      refProvider: syncRefJsonProvider,
    );

    final isValid = schema.validate({
      "meta": "a string",
      "nodes": [
        {
          "value": 123,
          "subtree": {"meta": "a string", "nodes": []}
        }
      ]
    });

    final isInvalid = schema.validate({
      "meta": "a string",
      "nodes": [
        {
          "value": 123,
          "subtree": {
            "meta": "a string",
            "nodes": [
              {
                "value": 123,
                "subtree": {"meta": 123, "nodes": []}
              }
            ]
          }
        }
      ]
    });

    expect(isValid, isTrue);
    expect(isInvalid, isFalse);
  });
}
