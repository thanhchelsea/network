import 'dart:io';
import 'package:dio/dio.dart';
import 'network_exceptions.dart';

/// Custom exception from dio error
class ApiException implements Exception {
  ApiException({
    this.succeeded,
    this.errors,
    this.data,
  });

  factory ApiException.fromDioError(DioException error) {
    return ApiException(
      succeeded: error.response?.data['succeeded'] as bool?,
      errors:
          List<String>.from(error.response?.data['errors'] as List<dynamic>),
      data: error.response?.data['data'],
    );
  }
  dynamic data;
  List<String>? errors;
  bool? succeeded;
}

extension HandleExceptionExtensions<T> on Future<T> {
  Future<T> get onApiError {
    return onError(
      (exception, stackTrace) {
        final DioException dioError = exception as DioException;
        if (dioError.response != null &&
            dioError.response?.statusCode != HttpStatus.ok) {
          throw ApiException.fromDioError(dioError);
        } else {
          final NetworkExceptions exceptions =
              NetworkExceptions.getDioException(exception);
          throw exceptions;
        }
      },
      test: (exception) {
        return exception is DioException;
      },
    );
  }
}
