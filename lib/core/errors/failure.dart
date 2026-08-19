import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String messageKey;

  const Failure(this.messageKey);

  @override
  List<Object?> get props => [messageKey];
}

class ServerFailure extends Failure {
  const ServerFailure([super.messageKey = 'auth_errors.generic_error']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.messageKey = 'auth_errors.user_not_found']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.messageKey = 'common.not_found']);
}

class InsufficientBalanceFailure extends Failure {
  const InsufficientBalanceFailure([super.messageKey = 'merchant.insufficient_balance']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.messageKey = 'common.cache_error']);
}

class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}
