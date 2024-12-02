import 'package:network/network.dart';
import 'dio.dart';

class NetworkPackage {
  void init({
    required String baseUrl,
    required GetAccessToken getGetAccessToken,
  }) {
    DioModule.setup(baseUrl: baseUrl, getGetAccessToken: getGetAccessToken);
  }
}
