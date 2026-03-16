class ApiException implements Exception{
  final String message;
  final int? statusCode;
  ApiException(this.message,{this.statusCode});
  @override
  String toString()=>'ApiException: $message';
}
class BadRequestException extends ApiException{
  BadRequestException(super.message): super(statusCode:400);
}
class UnauthorizedException extends ApiException{
  UnauthorizedException(super.message): super(statusCode: 401);
}
class ForbiddenException extends ApiException{
  ForbiddenException(super.message):super(statusCode:403);
}
class ServerException extends ApiException{
  ServerException(super.message): super(statusCode:500);
}
class NetworkException extends ApiException{
  NetworkException(super.message);
}