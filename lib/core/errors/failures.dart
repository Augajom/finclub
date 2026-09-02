/// Base Failure class for clean architecture error handling
abstract class Failure {
  final String message;
  final int? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred. Please try again.', int? code])
      : super(code: code);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection detected.', int? code])
      : super(code: code);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed. Please log in again.', int? code])
      : super(code: code);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load local cached data.', int? code])
      : super(code: code);
}
