// Base error types for the data layer to propagate meaningful domain errors.

class ApiError extends Error {
  final int statusCode;
  final String message;
  ApiError(this.statusCode, this.message);
  @override
  String toString() => 'ApiError($statusCode): $message';
}

class RateLimitError extends ApiError {
  final Duration? retryAfter;
  RateLimitError(super.statusCode, super.message, {this.retryAfter});
  @override
  String toString() => 'RateLimitError: retryAfter=$retryAfter, $message';
}

class AuthError extends ApiError {
  AuthError(super.statusCode, super.message);
}

class StorageError extends Error {
  final String message;
  StorageError(this.message);
  @override
  String toString() => 'StorageError: $message';
}

class ParseError extends Error {
  final String rawResponse;
  ParseError(this.rawResponse);
  @override
  String toString() => 'ParseError: $rawResponse';
}
