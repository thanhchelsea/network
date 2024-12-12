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
const String newDioWithBase = 'newDioWithBase';
var getInstance = GetIt.instance;

class DioModule {
  // DioModule._();
  static final GetIt _injector = GetIt.instance;

  String get getInstanceName => newDioWithBase;
  static void setup({
    String? baseUrl,
    GetAccessToken? getGetAccessToken,
    Function(Response<dynamic> res, ResponseInterceptorHandler han)? onResponse,
    String? dioNameForNewDev,
  }) {
    _setupDio(
      baseUrl: baseUrl,
      getGetAccessToken: getGetAccessToken,
      dioNameForNewDev: dioNameForNewDev,
      onResponse: onResponse,
    );
  }

  static void _setupDio({
    String? baseUrl,
    GetAccessToken? getGetAccessToken,
    Function(Response<dynamic> res, ResponseInterceptorHandler han)? onResponse,
    String? dioNameForNewDev,
  }) {
    /// Dio
    _injector.registerLazySingleton<Dio>(
      () {
        final Dio dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? '',
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
              //thằng này để lấy header của dio đã có trong moon, không đụng vào sửa được. nohope lắm
              options.headers = {..._injector<Dio>().options.headers};
              // String authorization = getGetAccessToken.call() != null ? 'Bearer ${getGetAccessToken.call()}' : '';
              // options.headers['Authorization'] = authorization;
              handler.next(options);
            },
            onResponse: (response, handler) {
              if (onResponse != null) {
                onResponse.call(response, handler);
              } else {
                handleResponse(response, handler);
              }
            },
            onError: (e, handler) async {
              logger.d('onError dio_module: $e');
              return handler.next(e);
            },
          ),
        );

        return dio;
      },
      instanceName: dioNameForNewDev ?? newDioWithBase,
    );
  }

  static void handleResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    //kiểm tra trạng thái success hay không ?
    if (response.data['succeeded'] != ResponseConfig.success) {
      debugPrint('API ERROR: ');
      handler.reject(
        DioException(
          requestOptions: RequestOptions(),
          response: Response(
            requestOptions: RequestOptions(),
            statusMessage: (response.data['errors'] as List<String>).join(' ,'),
            // statusCode: e.data['status'],
            data: response.data,
          ),
        ),
      );
    } else {
      debugPrint('API SUCCESSFULLY: ');
      final dataResponse = Response(
        data: response.data,
        requestOptions: RequestOptions(),
      );
      handler.next(dataResponse);
    }
  }
}

// {
//     "data": {
//     },
//     "succeeded": true,
//     "errors": []
// }