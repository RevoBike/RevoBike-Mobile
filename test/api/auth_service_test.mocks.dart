// Mocks generated by Mockito 5.4.5 from annotations
// in revobike/test/api/auth_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i9;

import 'package:dio/src/adapter.dart' as _i3;
import 'package:dio/src/cancel_token.dart' as _i10;
import 'package:dio/src/dio.dart' as _i7;
import 'package:dio/src/dio_mixin.dart' as _i5;
import 'package:dio/src/options.dart' as _i2;
import 'package:dio/src/response.dart' as _i6;
import 'package:dio/src/transformer.dart' as _i4;
import 'package:flutter/foundation.dart' as _i11;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i8;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeBaseOptions_0 extends _i1.SmartFake implements _i2.BaseOptions {
  _FakeBaseOptions_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeHttpClientAdapter_1 extends _i1.SmartFake
    implements _i3.HttpClientAdapter {
  _FakeHttpClientAdapter_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeTransformer_2 extends _i1.SmartFake implements _i4.Transformer {
  _FakeTransformer_2(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeInterceptors_3 extends _i1.SmartFake implements _i5.Interceptors {
  _FakeInterceptors_3(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeResponse_4<T1> extends _i1.SmartFake implements _i6.Response<T1> {
  _FakeResponse_4(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeDio_5 extends _i1.SmartFake implements _i7.Dio {
  _FakeDio_5(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeIOSOptions_6 extends _i1.SmartFake implements _i8.IOSOptions {
  _FakeIOSOptions_6(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeAndroidOptions_7 extends _i1.SmartFake
    implements _i8.AndroidOptions {
  _FakeAndroidOptions_7(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeLinuxOptions_8 extends _i1.SmartFake implements _i8.LinuxOptions {
  _FakeLinuxOptions_8(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeWindowsOptions_9 extends _i1.SmartFake
    implements _i8.WindowsOptions {
  _FakeWindowsOptions_9(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeWebOptions_10 extends _i1.SmartFake implements _i8.WebOptions {
  _FakeWebOptions_10(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeMacOsOptions_11 extends _i1.SmartFake implements _i8.MacOsOptions {
  _FakeMacOsOptions_11(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [Dio].
///
/// See the documentation for Mockito's code generation for more information.
class MockDio extends _i1.Mock implements _i7.Dio {
  MockDio() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.BaseOptions get options =>
      (super.noSuchMethod(
            Invocation.getter(#options),
            returnValue: _FakeBaseOptions_0(this, Invocation.getter(#options)),
          )
          as _i2.BaseOptions);

  @override
  set options(_i2.BaseOptions? _options) => super.noSuchMethod(
    Invocation.setter(#options, _options),
    returnValueForMissingStub: null,
  );

  @override
  _i3.HttpClientAdapter get httpClientAdapter =>
      (super.noSuchMethod(
            Invocation.getter(#httpClientAdapter),
            returnValue: _FakeHttpClientAdapter_1(
              this,
              Invocation.getter(#httpClientAdapter),
            ),
          )
          as _i3.HttpClientAdapter);

  @override
  set httpClientAdapter(_i3.HttpClientAdapter? _httpClientAdapter) =>
      super.noSuchMethod(
        Invocation.setter(#httpClientAdapter, _httpClientAdapter),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Transformer get transformer =>
      (super.noSuchMethod(
            Invocation.getter(#transformer),
            returnValue: _FakeTransformer_2(
              this,
              Invocation.getter(#transformer),
            ),
          )
          as _i4.Transformer);

  @override
  set transformer(_i4.Transformer? _transformer) => super.noSuchMethod(
    Invocation.setter(#transformer, _transformer),
    returnValueForMissingStub: null,
  );

  @override
  _i5.Interceptors get interceptors =>
      (super.noSuchMethod(
            Invocation.getter(#interceptors),
            returnValue: _FakeInterceptors_3(
              this,
              Invocation.getter(#interceptors),
            ),
          )
          as _i5.Interceptors);

  @override
  void close({bool? force = false}) => super.noSuchMethod(
    Invocation.method(#close, [], {#force: force}),
    returnValueForMissingStub: null,
  );

  @override
  _i9.Future<_i6.Response<T>> head<T>(
    String? path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    _i2.Options? options,
    _i10.CancelToken? cancelToken,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #head,
              [path],
              {
                #data: data,
                #queryParameters: queryParameters,
                #options: options,
                #cancelToken: cancelToken,
              },
            ),
            returnValue: _i9.Future<_i6.Response<T>>.value(
              _FakeResponse_4<T>(
                this,
                Invocation.method(
                  #head,
                  [path],
                  {
                    #data: data,
                    #queryParameters: queryParameters,
                    #options: options,
                    #cancelToken: cancelToken,
                  },
                ),
              ),
            ),
          )
          as _i9.Future<_i6.Response<T>>);

  @override
  _i9.Future<_i6.Response<T>> headUri<T>(
    Uri? uri, {
    Object? data,
    _i2.Options? options,
    _i10.CancelToken? cancelToken,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #headUri,
              [uri],
              {#data: data, #options: options, #cancelToken: cancelToken},
            ),
            returnValue: _i9.Future<_i6.Response<T>>.value(
              _FakeResponse_4<T>(
                this,
                Invocation.method(
                  #headUri,
                  [uri],
                  {#data: data, #options: options, #cancelToken: cancelToken},
                ),
              ),
            ),
          )
          as _i9.Future<_i6.Response<T>>);

  @override
  _i9.Future<_i6.Response<T>> get<T>(
    String? path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    _i2.Options? options,
    _i10.CancelToken? cancelToken,
    _i2.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #get,
              [path],
              {
                #data: data,
                #queryParameters: queryParameters,
                #options: options,
                #cancelToken: cancelToken,
                #onReceiveProgress: onReceiveProgress,
              },
            ),
            returnValue: _i9.Future<_i6.Response<T>>.value(
              _FakeResponse_4<T>(
                this,
                Invocation.method(
                  #get,
                  [path],
                  {
                    #data: data,
                    #queryParameters: queryParameters,
                    #options: options,
                    #cancelToken: cancelToken,
                    #onReceiveProgress: onReceiveProgress,
                  },
                ),
              ),
            ),
          )
          as _i9.Future<_i6.Response<T>>);

  @override
  _i9.Future<_i6.Response<T>> getUri<T>(
    Uri? uri, {
    Object? data,
    _i2.Options? options,
    _i10.CancelToken? cancelToken,
    _i2.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #getUri,
              [uri],
              {
                #data: data,
                #options: options,
                #cancelToken: cancelToken,
                #onReceiveProgress: onReceiveProgress,
              },
            ),
            returnValue: _i9.Future<_i6.Response<T>>.value(
              _FakeResponse_4<T>(
                this,
                Invocation.method(
                  #getUri,
                  [uri],
                  {
                    #data: data,
                    #options: options,
                    #cancelToken: cancelToken,
                    #onReceiveProgress: onReceiveProgress,
                  },
                ),
              ),
            ),
          )
          as _i9.Future<_i6.Response<T>>);

  @override
  _i9.Future<_i6.Response<T>> post<T>(
    String? path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    _i2.Options? options,
    _i10.CancelToken? cancelToken,
    _i2.ProgressCallback? onSendProgress,
    _i2.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #post,
              [path],
              {
                #data: data,
                #queryParameters: queryParameters,
                #options: options,
                #cancelToken: cancelToken,
                #onSendProgress: onSendProgress,
                #onReceiveProgress: onReceiveProgress,
              },
            ),
            returnValue: _i9.Future<_i6.Response<T>>.value(
              _FakeResponse_4<T>(
                this,
                Invocation.method(
                  #post,
                  [path],
                  {
                    #data: data,
                    #queryParameters: queryParameters,
                    #options: options,
                    #cancelToken: cancelToken,
                    #onSendProgress: onSendProgress,
                    #onReceiveProgress: onReceiveProgress,
                  },
                ),
              ),
            ),
          )
          as _i9.Future<_i6.Response<T>>);

  @override
  _i9.Future<_i6.Response<T>> postUri<T>(
    Uri? uri, {
    Object? data,
    _i2.Options? options,
    _i10.CancelToken? cancelToken,
    _i2.ProgressCallback? onSendProgress,
    _i2.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #postUri,
              [uri],
              {
                #data: data,
                #options: options,
                #cancelToken: cancelToken,
                #onSendProgress: onSendProgress,
                #onReceiveProgress: onReceiveProgress,
              },
            ),
            returnValue: _i9.Future<_i6.Response<T>>.value(
              _FakeResponse_4<T>(
                this,
                Invocation.method(
                  #postUri,
                  [uri],
                  {
                    #data: data,
                    #options: options,
                    #cancelToken: cancelToken,
                    #onSendProgress: onSendProgress,
                    #onReceiveProgress: onReceiveProgress,
                  },
                ),
              ),
            ),
          )
          as _i9.Future<_i6.Response<T>>);

  @override
  _i9.Future<_i6.Response<T>> put<T>(
    String? path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    _i2.Options? options,
    _i10.CancelToken? cancelToken,
    _i2.ProgressCallback? onSendProgress,
    _i2.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #put,
              [path],
              {
                #data: data,
                #queryParameters: queryParameters,
                #options: options,
                #cancelToken: cancelToken,
                #onSendProgress: onSendProgress,
                #onReceiveProgress: onReceiveProgress,
              },
            ),
            returnValue: _i9.Future<_i6.Response<T>>.value(
              _FakeResponse_4<T>(
                this,
                Invocation.method(
                  #put,
                  [path],
                  {
                    #data: data,
                    #queryParameters: queryParameters,
                    #options: options,
                    #cancelToken: cancelToken,
                    #onSendProgress: onSendProgress,
                    #onReceiveProgress: onReceiveProgress,
                  },
                ),
              ),
            ),
          )
          as _i9.Future<_i6.Response<T>>);

  @override
  _i9.Future<_i6.Response<T>> putUri<T>(
    Uri? uri, {
    Object? data,
    _i2.Options? options,
    _i10.CancelToken? cancelToken,
    _i2.ProgressCallback? onSendProgress,
    _i2.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #putUri,
              [uri],
              {
                #data: data,
                #options: options,
                #cancelToken: cancelToken,
                #onSendProgress: onSendProgress,
                #onReceiveProgress: onReceiveProgress,
              },
            ),
            returnValue: _i9.Future<_i6.Response<T>>.value(
              _FakeResponse_4<T>(
                this,
                Invocation.method(
                  #putUri,
                  [uri],
                  {
                    #data: data,
                    #options: options,
                    #cancelToken: cancelToken,
                    #onSendProgress: onSendProgress,
                    #onReceiveProgress: onReceiveProgress,
                  },
                ),
              ),
            ),
          )
          as _i9.Future<_i6.Response<T>>);

  @override
  _i9.Future<_i6.Response<T>> patch<T>(
    String? path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    _i2.Options? options,
    _i10.CancelToken? cancelToken,
    _i2.ProgressCallback? onSendProgress,
    _i2.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #patch,
              [path],
              {
                #data: data,
                #queryParameters: queryParameters,
                #options: options,
                #cancelToken: cancelToken,
                #onSendProgress: onSendProgress,
                #onReceiveProgress: onReceiveProgress,
              },
            ),
            returnValue: _i9.Future<_i6.Response<T>>.value(
              _FakeResponse_4<T>(
                this,
                Invocation.method(
                  #patch,
                  [path],
                  {
                    #data: data,
                    #queryParameters: queryParameters,
                    #options: options,
                    #cancelToken: cancelToken,
                    #onSendProgress: onSendProgress,
                    #onReceiveProgress: onReceiveProgress,
                  },
                ),
              ),
            ),
          )
          as _i9.Future<_i6.Response<T>>);

  @override
  _i9.Future<_i6.Response<T>> patchUri<T>(
    Uri? uri, {
    Object? data,
    _i2.Options? options,
    _i10.CancelToken? cancelToken,
    _i2.ProgressCallback? onSendProgress,
    _i2.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #patchUri,
              [uri],
              {
                #data: data,
                #options: options,
                #cancelToken: cancelToken,
                #onSendProgress: onSendProgress,
                #onReceiveProgress: onReceiveProgress,
              },
            ),
            returnValue: _i9.Future<_i6.Response<T>>.value(
              _FakeResponse_4<T>(
                this,
                Invocation.method(
                  #patchUri,
                  [uri],
                  {
                    #data: data,
                    #options: options,
                    #cancelToken: cancelToken,
                    #onSendProgress: onSendProgress,
                    #onReceiveProgress: onReceiveProgress,
                  },
                ),
              ),
            ),
          )
          as _i9.Future<_i6.Response<T>>);

  @override
  _i9.Future<_i6.Response<T>> delete<T>(
    String? path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    _i2.Options? options,
    _i10.CancelToken? cancelToken,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #delete,
              [path],
              {
                #data: data,
                #queryParameters: queryParameters,
                #options: options,
                #cancelToken: cancelToken,
              },
            ),
            returnValue: _i9.Future<_i6.Response<T>>.value(
              _FakeResponse_4<T>(
                this,
                Invocation.method(
                  #delete,
                  [path],
                  {
                    #data: data,
                    #queryParameters: queryParameters,
                    #options: options,
                    #cancelToken: cancelToken,
                  },
                ),
              ),
            ),
          )
          as _i9.Future<_i6.Response<T>>);

  @override
  _i9.Future<_i6.Response<T>> deleteUri<T>(
    Uri? uri, {
    Object? data,
    _i2.Options? options,
    _i10.CancelToken? cancelToken,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #deleteUri,
              [uri],
              {#data: data, #options: options, #cancelToken: cancelToken},
            ),
            returnValue: _i9.Future<_i6.Response<T>>.value(
              _FakeResponse_4<T>(
                this,
                Invocation.method(
                  #deleteUri,
                  [uri],
                  {#data: data, #options: options, #cancelToken: cancelToken},
                ),
              ),
            ),
          )
          as _i9.Future<_i6.Response<T>>);

  @override
  _i9.Future<_i6.Response<dynamic>> download(
    String? urlPath,
    dynamic savePath, {
    _i2.ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    _i10.CancelToken? cancelToken,
    bool? deleteOnError = true,
    _i2.FileAccessMode? fileAccessMode = _i2.FileAccessMode.write,
    String? lengthHeader = 'content-length',
    Object? data,
    _i2.Options? options,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #download,
              [urlPath, savePath],
              {
                #onReceiveProgress: onReceiveProgress,
                #queryParameters: queryParameters,
                #cancelToken: cancelToken,
                #deleteOnError: deleteOnError,
                #fileAccessMode: fileAccessMode,
                #lengthHeader: lengthHeader,
                #data: data,
                #options: options,
              },
            ),
            returnValue: _i9.Future<_i6.Response<dynamic>>.value(
              _FakeResponse_4<dynamic>(
                this,
                Invocation.method(
                  #download,
                  [urlPath, savePath],
                  {
                    #onReceiveProgress: onReceiveProgress,
                    #queryParameters: queryParameters,
                    #cancelToken: cancelToken,
                    #deleteOnError: deleteOnError,
                    #fileAccessMode: fileAccessMode,
                    #lengthHeader: lengthHeader,
                    #data: data,
                    #options: options,
                  },
                ),
              ),
            ),
          )
          as _i9.Future<_i6.Response<dynamic>>);

  @override
  _i9.Future<_i6.Response<dynamic>> downloadUri(
    Uri? uri,
    dynamic savePath, {
    _i2.ProgressCallback? onReceiveProgress,
    _i10.CancelToken? cancelToken,
    bool? deleteOnError = true,
    _i2.FileAccessMode? fileAccessMode = _i2.FileAccessMode.write,
    String? lengthHeader = 'content-length',
    Object? data,
    _i2.Options? options,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #downloadUri,
              [uri, savePath],
              {
                #onReceiveProgress: onReceiveProgress,
                #cancelToken: cancelToken,
                #deleteOnError: deleteOnError,
                #fileAccessMode: fileAccessMode,
                #lengthHeader: lengthHeader,
                #data: data,
                #options: options,
              },
            ),
            returnValue: _i9.Future<_i6.Response<dynamic>>.value(
              _FakeResponse_4<dynamic>(
                this,
                Invocation.method(
                  #downloadUri,
                  [uri, savePath],
                  {
                    #onReceiveProgress: onReceiveProgress,
                    #cancelToken: cancelToken,
                    #deleteOnError: deleteOnError,
                    #fileAccessMode: fileAccessMode,
                    #lengthHeader: lengthHeader,
                    #data: data,
                    #options: options,
                  },
                ),
              ),
            ),
          )
          as _i9.Future<_i6.Response<dynamic>>);

  @override
  _i9.Future<_i6.Response<T>> request<T>(
    String? url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    _i10.CancelToken? cancelToken,
    _i2.Options? options,
    _i2.ProgressCallback? onSendProgress,
    _i2.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #request,
              [url],
              {
                #data: data,
                #queryParameters: queryParameters,
                #cancelToken: cancelToken,
                #options: options,
                #onSendProgress: onSendProgress,
                #onReceiveProgress: onReceiveProgress,
              },
            ),
            returnValue: _i9.Future<_i6.Response<T>>.value(
              _FakeResponse_4<T>(
                this,
                Invocation.method(
                  #request,
                  [url],
                  {
                    #data: data,
                    #queryParameters: queryParameters,
                    #cancelToken: cancelToken,
                    #options: options,
                    #onSendProgress: onSendProgress,
                    #onReceiveProgress: onReceiveProgress,
                  },
                ),
              ),
            ),
          )
          as _i9.Future<_i6.Response<T>>);

  @override
  _i9.Future<_i6.Response<T>> requestUri<T>(
    Uri? uri, {
    Object? data,
    _i10.CancelToken? cancelToken,
    _i2.Options? options,
    _i2.ProgressCallback? onSendProgress,
    _i2.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #requestUri,
              [uri],
              {
                #data: data,
                #cancelToken: cancelToken,
                #options: options,
                #onSendProgress: onSendProgress,
                #onReceiveProgress: onReceiveProgress,
              },
            ),
            returnValue: _i9.Future<_i6.Response<T>>.value(
              _FakeResponse_4<T>(
                this,
                Invocation.method(
                  #requestUri,
                  [uri],
                  {
                    #data: data,
                    #cancelToken: cancelToken,
                    #options: options,
                    #onSendProgress: onSendProgress,
                    #onReceiveProgress: onReceiveProgress,
                  },
                ),
              ),
            ),
          )
          as _i9.Future<_i6.Response<T>>);

  @override
  _i9.Future<_i6.Response<T>> fetch<T>(_i2.RequestOptions? requestOptions) =>
      (super.noSuchMethod(
            Invocation.method(#fetch, [requestOptions]),
            returnValue: _i9.Future<_i6.Response<T>>.value(
              _FakeResponse_4<T>(
                this,
                Invocation.method(#fetch, [requestOptions]),
              ),
            ),
          )
          as _i9.Future<_i6.Response<T>>);

  @override
  _i7.Dio clone({
    _i2.BaseOptions? options,
    _i5.Interceptors? interceptors,
    _i3.HttpClientAdapter? httpClientAdapter,
    _i4.Transformer? transformer,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#clone, [], {
              #options: options,
              #interceptors: interceptors,
              #httpClientAdapter: httpClientAdapter,
              #transformer: transformer,
            }),
            returnValue: _FakeDio_5(
              this,
              Invocation.method(#clone, [], {
                #options: options,
                #interceptors: interceptors,
                #httpClientAdapter: httpClientAdapter,
                #transformer: transformer,
              }),
            ),
          )
          as _i7.Dio);
}

/// A class which mocks [FlutterSecureStorage].
///
/// See the documentation for Mockito's code generation for more information.
class MockFlutterSecureStorage extends _i1.Mock
    implements _i8.FlutterSecureStorage {
  MockFlutterSecureStorage() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i8.IOSOptions get iOptions =>
      (super.noSuchMethod(
            Invocation.getter(#iOptions),
            returnValue: _FakeIOSOptions_6(this, Invocation.getter(#iOptions)),
          )
          as _i8.IOSOptions);

  @override
  _i8.AndroidOptions get aOptions =>
      (super.noSuchMethod(
            Invocation.getter(#aOptions),
            returnValue: _FakeAndroidOptions_7(
              this,
              Invocation.getter(#aOptions),
            ),
          )
          as _i8.AndroidOptions);

  @override
  _i8.LinuxOptions get lOptions =>
      (super.noSuchMethod(
            Invocation.getter(#lOptions),
            returnValue: _FakeLinuxOptions_8(
              this,
              Invocation.getter(#lOptions),
            ),
          )
          as _i8.LinuxOptions);

  @override
  _i8.WindowsOptions get wOptions =>
      (super.noSuchMethod(
            Invocation.getter(#wOptions),
            returnValue: _FakeWindowsOptions_9(
              this,
              Invocation.getter(#wOptions),
            ),
          )
          as _i8.WindowsOptions);

  @override
  _i8.WebOptions get webOptions =>
      (super.noSuchMethod(
            Invocation.getter(#webOptions),
            returnValue: _FakeWebOptions_10(
              this,
              Invocation.getter(#webOptions),
            ),
          )
          as _i8.WebOptions);

  @override
  _i8.MacOsOptions get mOptions =>
      (super.noSuchMethod(
            Invocation.getter(#mOptions),
            returnValue: _FakeMacOsOptions_11(
              this,
              Invocation.getter(#mOptions),
            ),
          )
          as _i8.MacOsOptions);

  @override
  void registerListener({
    required String? key,
    required _i11.ValueChanged<String?>? listener,
  }) => super.noSuchMethod(
    Invocation.method(#registerListener, [], {#key: key, #listener: listener}),
    returnValueForMissingStub: null,
  );

  @override
  void unregisterListener({
    required String? key,
    required _i11.ValueChanged<String?>? listener,
  }) => super.noSuchMethod(
    Invocation.method(#unregisterListener, [], {
      #key: key,
      #listener: listener,
    }),
    returnValueForMissingStub: null,
  );

  @override
  void unregisterAllListenersForKey({required String? key}) =>
      super.noSuchMethod(
        Invocation.method(#unregisterAllListenersForKey, [], {#key: key}),
        returnValueForMissingStub: null,
      );

  @override
  void unregisterAllListeners() => super.noSuchMethod(
    Invocation.method(#unregisterAllListeners, []),
    returnValueForMissingStub: null,
  );

  @override
  _i9.Future<void> write({
    required String? key,
    required String? value,
    _i8.IOSOptions? iOptions,
    _i8.AndroidOptions? aOptions,
    _i8.LinuxOptions? lOptions,
    _i8.WebOptions? webOptions,
    _i8.MacOsOptions? mOptions,
    _i8.WindowsOptions? wOptions,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#write, [], {
              #key: key,
              #value: value,
              #iOptions: iOptions,
              #aOptions: aOptions,
              #lOptions: lOptions,
              #webOptions: webOptions,
              #mOptions: mOptions,
              #wOptions: wOptions,
            }),
            returnValue: _i9.Future<void>.value(),
            returnValueForMissingStub: _i9.Future<void>.value(),
          )
          as _i9.Future<void>);

  @override
  _i9.Future<String?> read({
    required String? key,
    _i8.IOSOptions? iOptions,
    _i8.AndroidOptions? aOptions,
    _i8.LinuxOptions? lOptions,
    _i8.WebOptions? webOptions,
    _i8.MacOsOptions? mOptions,
    _i8.WindowsOptions? wOptions,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#read, [], {
              #key: key,
              #iOptions: iOptions,
              #aOptions: aOptions,
              #lOptions: lOptions,
              #webOptions: webOptions,
              #mOptions: mOptions,
              #wOptions: wOptions,
            }),
            returnValue: _i9.Future<String?>.value(),
          )
          as _i9.Future<String?>);

  @override
  _i9.Future<bool> containsKey({
    required String? key,
    _i8.IOSOptions? iOptions,
    _i8.AndroidOptions? aOptions,
    _i8.LinuxOptions? lOptions,
    _i8.WebOptions? webOptions,
    _i8.MacOsOptions? mOptions,
    _i8.WindowsOptions? wOptions,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#containsKey, [], {
              #key: key,
              #iOptions: iOptions,
              #aOptions: aOptions,
              #lOptions: lOptions,
              #webOptions: webOptions,
              #mOptions: mOptions,
              #wOptions: wOptions,
            }),
            returnValue: _i9.Future<bool>.value(false),
          )
          as _i9.Future<bool>);

  @override
  _i9.Future<void> delete({
    required String? key,
    _i8.IOSOptions? iOptions,
    _i8.AndroidOptions? aOptions,
    _i8.LinuxOptions? lOptions,
    _i8.WebOptions? webOptions,
    _i8.MacOsOptions? mOptions,
    _i8.WindowsOptions? wOptions,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#delete, [], {
              #key: key,
              #iOptions: iOptions,
              #aOptions: aOptions,
              #lOptions: lOptions,
              #webOptions: webOptions,
              #mOptions: mOptions,
              #wOptions: wOptions,
            }),
            returnValue: _i9.Future<void>.value(),
            returnValueForMissingStub: _i9.Future<void>.value(),
          )
          as _i9.Future<void>);

  @override
  _i9.Future<Map<String, String>> readAll({
    _i8.IOSOptions? iOptions,
    _i8.AndroidOptions? aOptions,
    _i8.LinuxOptions? lOptions,
    _i8.WebOptions? webOptions,
    _i8.MacOsOptions? mOptions,
    _i8.WindowsOptions? wOptions,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#readAll, [], {
              #iOptions: iOptions,
              #aOptions: aOptions,
              #lOptions: lOptions,
              #webOptions: webOptions,
              #mOptions: mOptions,
              #wOptions: wOptions,
            }),
            returnValue: _i9.Future<Map<String, String>>.value(
              <String, String>{},
            ),
          )
          as _i9.Future<Map<String, String>>);

  @override
  _i9.Future<void> deleteAll({
    _i8.IOSOptions? iOptions,
    _i8.AndroidOptions? aOptions,
    _i8.LinuxOptions? lOptions,
    _i8.WebOptions? webOptions,
    _i8.MacOsOptions? mOptions,
    _i8.WindowsOptions? wOptions,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#deleteAll, [], {
              #iOptions: iOptions,
              #aOptions: aOptions,
              #lOptions: lOptions,
              #webOptions: webOptions,
              #mOptions: mOptions,
              #wOptions: wOptions,
            }),
            returnValue: _i9.Future<void>.value(),
            returnValueForMissingStub: _i9.Future<void>.value(),
          )
          as _i9.Future<void>);

  @override
  _i9.Future<bool?> isCupertinoProtectedDataAvailable() =>
      (super.noSuchMethod(
            Invocation.method(#isCupertinoProtectedDataAvailable, []),
            returnValue: _i9.Future<bool?>.value(),
          )
          as _i9.Future<bool?>);
}
