import 'api_exception.dart';
import 'network_exceptions.dart';

class ExceptionHelper {
  ExceptionHelper._();

  static void handleBaseException({
    required dynamic e,
    required Function(ApiException apiException) onApiException,
    Function(BadRequest badRequest)? onBadRequest,
    Function(NotFound notFound)? onNotFound,
    Function(MethodNotAllowed methodNotAllowed)? onMethodNotAllowed,
    Function(RequestTimeout requestTimeout)? onRequestTimeOut,
    Function(FormatException formatException)? onFormatException,
    Function(UnableToProcess unableToProcess)? onUnableToProcess,
    Function(NetworkExceptions networkExceptions)? onNetworkException,
    Function(InternalServerError internalServerError)? onInternalServerError,
    Function(TypeError typeError)? onTypeErrorException,
    Function(dynamic exception)? onUnKnowException,
  }) {
    if (e is ApiException) {
      onApiException.call(e);
    } else if (e is BadRequest) {
      onBadRequest?.call(e);
    } else if (e is NotFound) {
      onNetworkException?.call(e);
    } else if (e is MethodNotAllowed) {
      onMethodNotAllowed?.call(e);
    } else if (e is RequestTimeout) {
      onRequestTimeOut?.call(e);
    } else if (e is FormatException) {
      onFormatException?.call(e);
    } else if (e is UnableToProcess) {
      onUnableToProcess?.call(e);
    } else if (e is NetworkExceptions) {
      onNetworkException?.call(e);
    } else if (e is InternalServerError) {
      onInternalServerError?.call(e);
    } else if (e is TypeError) {
      onTypeErrorException?.call(e);
    } else {
      onUnKnowException?.call(e);
    }
  }
}
