class AppException implements Exception {
  AppException({
    this.code,
    this.message,
  });

  String? message;
  int? code;
}
