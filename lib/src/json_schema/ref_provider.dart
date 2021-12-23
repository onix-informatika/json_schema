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

import 'package:json_schema/json_schema.dart';
import 'package:json_schema/src/json_schema/schema_url_client/stub_schema_url_client.dart'
    if (dart.library.html) 'package:json_schema/src/json_schema/schema_url_client/html_schema_url_client.dart'
    if (dart.library.io) 'package:json_schema/src/json_schema/schema_url_client/io_schema_url_client.dart';

typedef SyncSchemaProvider = JsonSchema Function(String ref);
typedef SyncJsonProvider = Map<String, dynamic> Function(String ref);
typedef AsyncJsonProvider = Future<Map<String, dynamic>> Function(String ref);
typedef AsyncSchemaProvider = Future<JsonSchema> Function(String ref);

enum RefProviderType {
  @Deprecated('Use RefProviderType.json instead, renamed with deprecation of JsonSchema RefProviders.')
  schema,
  json,
}

class RefProvider<T> {
  RefProvider(this.provide, this.type, this.isSync);

  @Deprecated('Use RefProvider.sync instead, it can resolve nested schema references more effectively.')
  static RefProvider syncSchema(SyncSchemaProvider provider) {
    return RefProvider<SyncSchemaProvider>(
      provider,
      RefProviderType.schema,
      true,
    );
  }

  @Deprecated('Use RefProvider.async instead, it can resolve nested schema references more effectively.')
  static RefProvider asyncSchema(AsyncSchemaProvider provider) {
    return RefProvider<AsyncSchemaProvider>(
      provider,
      RefProviderType.schema,
      false,
    );
  }

  @Deprecated('Use RefProvider.sync instead, renamed with deprecation of JsonSchema RefProviders.')
  static RefProvider syncJson(SyncJsonProvider provider) {
    return RefProvider.sync(provider);
  }

  @Deprecated('Use RefProvider.sync instead, renamed with deprecation of JsonSchema RefProviders.')
  static RefProvider asyncJson(AsyncJsonProvider provider) {
    return RefProvider.async(provider);
  }

  static RefProvider async(AsyncJsonProvider provider) {
    return RefProvider<AsyncJsonProvider>(
      provider,
      RefProviderType.json,
      false,
    );
  }

  static RefProvider sync(SyncJsonProvider provider) {
    return RefProvider<SyncJsonProvider>(
      provider,
      RefProviderType.json,
      true,
    );
  }

  final bool isSync;
  final RefProviderType type;
  final T provide;
}

final defaultHttpRefProvider = RefProvider.async((String ref) async {
  return await createClient()?.getSchemaJsonFromUrl(ref);
});
