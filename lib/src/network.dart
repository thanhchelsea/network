import 'package:dio/dio.dart';
import 'package:network/network.dart';
import 'dio.dart';

class NetworkPackage {
  void init({
    String? baseUrl,
    GetAccessToken? getGetAccessToken,
    Function(Response<dynamic> res, ResponseInterceptorHandler han)? onResponse,
    String? dioNameForNewDev,
  }) {
    DioModule.setup(
      baseUrl: baseUrl,
      getGetAccessToken: getGetAccessToken,
      dioNameForNewDev: dioNameForNewDev,
      onResponse: onResponse,
    );
  }
}
