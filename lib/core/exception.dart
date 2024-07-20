class ServerException implements Exception {
  final String message;
  final int code;
  ServerException({required this.message, this.code = 404});
}
