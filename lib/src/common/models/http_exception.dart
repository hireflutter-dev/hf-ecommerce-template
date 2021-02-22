class HttpException implements Exception {
  const HttpException(this.message);

  final String message;

  @override
  String toString() => message;
}
