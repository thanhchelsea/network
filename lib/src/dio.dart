//setup dio

// ignore_for_file: avoid_dynamic_calls

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:network/src/constants/constant.dart';
import 'package:network/src/model/page.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

Logger logger = Logger();

typedef GetAccessToken = String? Function();
const String dioInstanceName = 'dioInstance';

class DioModule {
  // DioModule._();
  static final GetIt _injector = GetIt.instance;

  String get getInstanceName => dioInstanceName;
  static void setup({
    required String baseUrl,
    required GetAccessToken getGetAccessToken,
  }) {
    _setupDio(
      baseUrl: baseUrl,
      getGetAccessToken: getGetAccessToken,
    );
  }

  static void _setupDio({
    required String baseUrl,
    required GetAccessToken getGetAccessToken,
  }) {
    /// Dio
    _injector.registerLazySingleton<Dio>(
      () {
        final Dio dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            sendTimeout: const Duration(seconds: DioConfig.timeout),
            receiveTimeout: const Duration(seconds: DioConfig.timeout),
            headers: {
              'Content-Type': 'application/json',
              'Accept-Language': 'vi',
            },
          ),
        );
        if (!kReleaseMode) {
          dio.interceptors.add(
            PrettyDioLogger(
              requestBody: true,
              requestHeader: true,
              //      responseHeader: true
            ),
          );
          dio.interceptors.add(PrettyDioLogger(
            requestBody: true,
            responseBody: true,
            responseHeader: true,
          ));
          dio.interceptors.add(
            CurlLoggerDioInterceptor(printOnSuccess: true),
          );
        }

        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              String authorization = getGetAccessToken.call() != null
                  ? 'Bearer ${getGetAccessToken.call()}'
                  : '';
              options.headers['Authorization'] = authorization;
              handler.next(options);
            },
            onResponse: handleResponse,
            onError: (e, handler) async {
              logger.d('onError dio_module: $e');
              return handler.next(e);
            },
          ),
        );

        return dio;
      },
      instanceName: dioInstanceName,
    );
  }

  static void handleResponse(
    Response<dynamic> e,
    ResponseInterceptorHandler handler,
  ) {
    if (e.data['succeeded'] != ResponseConfig.success) {
      debugPrint('API ERROR: ${e.data['succeeded']}');
      handler.reject(
        DioException(
          requestOptions: RequestOptions(),
          response: Response(
            requestOptions: RequestOptions(),
            statusMessage: (e.data['errors'] as List<String>).join(' ,'),
            // statusCode: e.data['status'],
            data: e.data,
          ),
        ),
      );
    } else {
      debugPrint('API SUCCESSFULLY: ${e.data['succeeded']}');
      final response = Response(
        data: e.data,
        requestOptions: RequestOptions(),
      );
      // final response = MoonResponse(
      //   page: e.data['page'] != null
      //       ? Page.fromJson(e.data['page'] as Map<String, dynamic>)
      //       : null,
      //   requestOptions: RequestOptions(),
      //   data: e.data['data'],
      // );
      handler.next(response);
    }
  }
}

class MoonResponse extends Response {
  Page? page;
  MoonResponse({
    this.page,
    required super.requestOptions,
    required super.data,
  });
}
