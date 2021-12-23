import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:json_schema/src/json_schema/constants.dart';
import 'package:json_schema/src/json_schema/json_schema.dart';
import 'package:json_schema/src/json_schema/schema_url_client/schema_url_client.dart';
import 'package:json_schema/src/json_schema/utils.dart';
import 'package:rfc_6901/rfc_6901.dart';

class HtmlSchemaUrlClient extends SchemaUrlClient {
  @override
  createFromUrl(String schemaUrl, {SchemaVersion schemaVersion}) async {
    final uriWithFrag = Uri.parse(schemaUrl);
    var uri = uriWithFrag.removeFragment();
    if (schemaUrl.endsWith('#')) {
      uri = uriWithFrag;
    }
    if (uri.scheme != 'file') {
      // _logger.info('Getting url $uri'); TODO: re-add logger.
      final response = await http.get(uri);

      var jsonResponse;
      if (response.statusCode == 200) {
        jsonResponse = json.decode(response.body);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load Schema from: $uri');
      }

      // HTTP servers ignore fragments, so resolve a sub-map if a fragment was specified.
      final parentSchema =
          await JsonSchema.createAsync(jsonResponse, schemaVersion: schemaVersion, fetchedFromUri: uri);
      final schema = JsonSchemaUtils.getSubMapFromFragment(parentSchema, uriWithFrag);
      return schema ?? parentSchema;
    } else {
      throw FormatException('Url schema must be http: $schemaUrl. To use a local file, use dart:io');
    }
  }

  @override
  Future<Map<String, dynamic>> getSchemaJsonFromUrl(String schemaUrl) async {
    final uriWithFrag = Uri.parse(schemaUrl);
    var uri = uriWithFrag.removeFragment();
    if (schemaUrl.endsWith('#')) {
      uri = uriWithFrag;
    }
    if (uri.scheme != 'file') {
      // _logger.info('Getting url $uri'); TODO: re-add logger.
      final response = await http.get(uri);

      var jsonResponse;
      if (response.statusCode == 200) {
        jsonResponse = json.decode(response.body);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load Schema from: $uri');
      }

      // HTTP servers ignore fragments, so resolve a sub-map if a fragment was specified.
      var subSchema;
      try {
        subSchema = JsonPointer(uriWithFrag.fragment)?.read(jsonResponse);
      } catch (_) {
        // Do nothing if we fail to decode or read the pointer.
      }
      return subSchema ?? jsonResponse;
    } else {
      throw FormatException('Url schema must be http: $schemaUrl. To use a local file, use dart:io');
    }
  }
}

/// Create a [BrowserClient].
///
/// Used from conditional imports, matches the definition in `stub_schema_url_client.dart`.
SchemaUrlClient createClient() => HtmlSchemaUrlClient();
