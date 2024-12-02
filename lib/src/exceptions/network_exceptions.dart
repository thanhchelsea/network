import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_exceptions.freezed.dart';

@freezed
abstract class NetworkExceptions with _$NetworkExceptions {
  const factory NetworkExceptions.requestCancelled() = RequestCancelled;

  const factory NetworkExceptions.unauthorizedRequest(String? reason) =
      UnauthorizedRequest;

  const factory NetworkExceptions.forbidden() = Forbidden;

  const factory NetworkExceptions.badRequest(
    String? reason,
    List<dynamic>? errors,
  ) = BadRequest;

  const factory NetworkExceptions.methodNotAllowed() = MethodNotAllowed;

  const factory NetworkExceptions.notFound(String reason) = NotFound;

  const factory NetworkExceptions.notAcceptable() = NotAcceptable;

  const factory NetworkExceptions.requestTimeOut() = RequestTimeout;

  const factory NetworkExceptions.sendTimeout() = SendTimeout;

  const factory NetworkExceptions.conflict() = Conflict;

  const factory NetworkExceptions.internalServerError() = InternalServerError;

  const factory NetworkExceptions.notImplemented() = NotImplemented;

  const factory NetworkExceptions.serviceUnavailable() = ServiceUnavailable;

  const factory NetworkExceptions.noInternetConnection() = NoInternetConnection;

  const factory NetworkExceptions.formatException() = FormatException;

  const factory NetworkExceptions.unableToProcess(String reason) =
      UnableToProcess;

  const factory NetworkExceptions.defaultError(dynamic data) = DefaultError;

  const factory NetworkExceptions.unexpectedError() = UnexpectedError;

  static NetworkExceptions handleResponse(dynamic data, int? statusCode) {
    String? message;

    if (data.toString().contains('errMessage')) {
      message = data['errMessage'].toString();
    }

    if (data.toString().contains('errCode')) {
      //TODO
    }

    if (data is String) {
      message = data;
    }

    switch (statusCode) {
      case 400:
        return NetworkExceptions.badRequest(
          data['message'] as String?,
          data['errors'] as List<dynamic>?,
        );
      case 403:
        return const NetworkExceptions.forbidden();
      case 401:
        return NetworkExceptions.unauthorizedRequest(
          message ?? 'Phiên đăng nhập hết hạn',
        );
      case 404:
        return NetworkExceptions.notFound(message ?? 'Not found');
      case 405:
        return const NetworkExceptions.methodNotAllowed();
      case 408:
        return const NetworkExceptions.requestTimeOut();
      case 409:
        return const NetworkExceptions.internalServerError();
      case 500:
        return const NetworkExceptions.internalServerError();
      default:
        return NetworkExceptions.defaultError(data['error']);
    }
  }

  static NetworkExceptions getDioException(error) {
    NetworkExceptions networkExceptions =
        const NetworkExceptions.unexpectedError();
    if (error is Exception) {
      try {
        if (error is DioException) {
          switch (error.type) {
            case DioExceptionType.cancel:
              networkExceptions = const NetworkExceptions.requestCancelled();
              break;
            case DioExceptionType.connectionTimeout:
              networkExceptions = const NetworkExceptions.requestTimeOut();
              break;

            case DioExceptionType.receiveTimeout:
              networkExceptions = const NetworkExceptions.sendTimeout();
              break;
            case DioExceptionType.badResponse:
              networkExceptions = NetworkExceptions.handleResponse(
                error.response?.data is String
                    ? json.decode(error.response?.data?.toString() ?? '')
                    : error.response?.data,
                error.response?.statusCode,
              );
              break;
            case DioExceptionType.sendTimeout:
              networkExceptions = const NetworkExceptions.sendTimeout();
              break;
            case DioExceptionType.badCertificate:
              const NetworkExceptions.unexpectedError();
              break;
            case DioExceptionType.connectionError:
              networkExceptions =
                  const NetworkExceptions.noInternetConnection();
              break;
            case DioExceptionType.unknown:
              networkExceptions = const NetworkExceptions.defaultError(
                'Có lỗi xảy ra. Vui lòng thử lại',
              );
              break;
          }
        } else if (error is SocketException) {
          networkExceptions = const NetworkExceptions.noInternetConnection();
        } else {
          networkExceptions = const NetworkExceptions.unexpectedError();
        }
        return networkExceptions;
      } on FormatException {
        return const NetworkExceptions.formatException();
      } catch (e) {
        return const NetworkExceptions.unexpectedError();
      }
    } else {
      if (error.toString().contains('is not a subtype of')) {
        final String errorString = error.toString();
        return NetworkExceptions.unableToProcess(errorString);
      } else {
        return const NetworkExceptions.unexpectedError();
      }
    }
  }

  static String getErrorMessage(NetworkExceptions networkExceptions) {
    var errorMessage = '';
    networkExceptions.when(
      notImplemented: () {
        errorMessage = 'Not Implemented';
      },
      requestCancelled: () {
        errorMessage = 'Request Cancelled';
      },
      internalServerError: () {
        errorMessage = 'Internal Server Error';
      },
      notFound: (String reason) {
        errorMessage = reason;
      },
      serviceUnavailable: () {
        errorMessage = 'Service unavailable';
      },
      methodNotAllowed: () {
        errorMessage = 'Method Allowed';
      },
      badRequest: (String? reason, List<dynamic>? listError) {
        errorMessage = reason ?? 'Bad request';
      },
      unauthorizedRequest: (reason) {
        errorMessage = reason ?? 'Unauthorized request';
      },
      unexpectedError: () {
        errorMessage = 'Unexpected error occurred';
      },
      requestTimeOut: () {
        errorMessage = 'Connection request timeout';
      },
      noInternetConnection: () {
        errorMessage = 'No internet connection';
      },
      conflict: () {
        errorMessage = 'Error due to a conflict';
      },
      sendTimeout: () {
        errorMessage = 'Send timeout in connection with API server';
      },
      unableToProcess: (String reason) {
        errorMessage = 'Unable to process the data $reason';
      },
      defaultError: (dynamic error) {
        errorMessage = error['message'].toString();
      },
      formatException: () {
        errorMessage = 'Unexpected error occurred';
      },
      notAcceptable: () {
        errorMessage = 'Not acceptable';
      },
      forbidden: () {
        errorMessage = 'Forbidden';
      },
    );
    return errorMessage;
  }
}
