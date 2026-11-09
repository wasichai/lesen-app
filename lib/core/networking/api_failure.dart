import 'package:dio/dio.dart';

/// Un fallo de la API ya clasificado. Las pantallas deciden qué decir según el tipo, nunca según el código HTTP.
sealed class ApiFailure implements Exception {
  const ApiFailure([this.detail]);

  final String? detail;

  /// Convierte cualquier error de dio (o de parseo) en un [ApiFailure].
  static ApiFailure from(Object error) {
    if (error is ApiFailure) return error;
    if (error is ContractException) return ContractFailure(error.message);
    if (error is! DioException) return UnknownFailure(error.toString());
    final inner = error.error;
    if (inner is ApiFailure) return inner;
    if (inner is ContractException) return ContractFailure(inner.message);
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const OfflineFailure();
      case DioExceptionType.cancel:
        return const CancelledFailure();
      case DioExceptionType.badCertificate:
        return const OfflineFailure('certificate');
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        final response = error.response;
        if (response == null) return const OfflineFailure();
        return fromResponse(response.statusCode ?? 0, response.data);
    }
  }

  /// Lee un `application/problem+json` (`{type, title, status, detail, errors[{field, message}]}`).
  static ApiFailure fromResponse(int status, Object? body) {
    final problem = body is Map ? body : const {};
    final detail = (problem['detail'] ?? problem['title'])?.toString();
    return switch (status) {
      400 || 422 => ValidationFailure(detail, _fieldErrors(problem['errors'])),
      401 => UnauthorizedFailure(detail),
      403 => ForbiddenFailure(detail),
      404 => NotFoundFailure(detail),
      409 => ConflictFailure(detail),
      429 => RateLimitedFailure(detail),
      >= 500 => ServerFailure(detail),
      _ => UnknownFailure(detail),
    };
  }

  static Map<String, String> _fieldErrors(Object? errors) {
    if (errors is! List) return const {};
    return {
      for (final e in errors.whereType<Map>())
        if (e['field'] != null) e['field'].toString(): (e['message'] ?? '').toString(),
    };
  }

  /// Si tiene sentido volver a intentarlo sin cambiar nada.
  bool get isTransient => this is OfflineFailure || this is TimeoutFailure || this is ServerFailure;

  @override
  String toString() => '$runtimeType(${detail ?? ''})';
}

class OfflineFailure extends ApiFailure {
  const OfflineFailure([super.detail]);
}

class TimeoutFailure extends ApiFailure {
  const TimeoutFailure([super.detail]);
}

class CancelledFailure extends ApiFailure {
  const CancelledFailure([super.detail]);
}

class UnauthorizedFailure extends ApiFailure {
  const UnauthorizedFailure([super.detail]);
}

class ForbiddenFailure extends ApiFailure {
  const ForbiddenFailure([super.detail]);
}

class NotFoundFailure extends ApiFailure {
  const NotFoundFailure([super.detail]);
}

class ConflictFailure extends ApiFailure {
  const ConflictFailure([super.detail]);
}

class RateLimitedFailure extends ApiFailure {
  const RateLimitedFailure([super.detail]);
}

class ValidationFailure extends ApiFailure {
  const ValidationFailure(super.detail, this.fields);

  final Map<String, String> fields;
}

class ServerFailure extends ApiFailure {
  const ServerFailure([super.detail]);
}

class ContractFailure extends ApiFailure {
  const ContractFailure([super.detail]);
}

class UnknownFailure extends ApiFailure {
  const UnknownFailure([super.detail]);
}

/// Una respuesta que no casa con lo que el cliente necesita (ADR-0004).
class ContractException implements Exception {
  const ContractException(this.message);

  final String message;

  @override
  String toString() => 'ContractException: $message';
}
