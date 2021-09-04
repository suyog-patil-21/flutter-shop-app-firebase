class HttpException implements Exception {
  final String meassage;
  HttpException(this.meassage);
  @override
  String toString() {
    return meassage;
  }
}
