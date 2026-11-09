import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesen/core/networking/api_failure.dart';

void main() {
  RequestOptions req() => RequestOptions(path: '/x');

  test('problem+json se clasifica por estado y conserva los errores de campo', () {
    final f = ApiFailure.fromResponse(400, {
      'status': 400,
      'detail': 'Datos no válidos',
      'errors': [
        {'field': 'dailyMinutes', 'message': 'debe estar entre 5 y 120'},
      ],
    });
    expect(f, isA<ValidationFailure>());
    expect((f as ValidationFailure).fields, {'dailyMinutes': 'debe estar entre 5 y 120'});
    expect(f.detail, 'Datos no válidos');
    expect(ApiFailure.fromResponse(401, null), isA<UnauthorizedFailure>());
    expect(ApiFailure.fromResponse(403, null), isA<ForbiddenFailure>());
    expect(ApiFailure.fromResponse(404, null), isA<NotFoundFailure>());
    expect(ApiFailure.fromResponse(409, null), isA<ConflictFailure>());
    expect(ApiFailure.fromResponse(429, null), isA<RateLimitedFailure>());
    expect(ApiFailure.fromResponse(503, null), isA<ServerFailure>());
  });

  test('errores de red y de tiempo de dio', () {
    expect(ApiFailure.from(DioException(requestOptions: req(), type: DioExceptionType.connectionError)), isA<OfflineFailure>());
    expect(ApiFailure.from(DioException(requestOptions: req(), type: DioExceptionType.receiveTimeout)), isA<TimeoutFailure>());
    expect(ApiFailure.from(DioException(requestOptions: req(), type: DioExceptionType.cancel)), isA<CancelledFailure>());
    final bad = DioException(
      requestOptions: req(),
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(requestOptions: req(), statusCode: 404, data: {'detail': 'no'}),
    );
    expect(ApiFailure.from(bad), isA<NotFoundFailure>());
  });

  test('una respuesta que no casa con el contrato es ContractFailure, no un fallo genérico', () {
    expect(ApiFailure.from(const ContractException('level')), isA<ContractFailure>());
  });

  test('solo lo transitorio se reintenta', () {
    expect(const OfflineFailure().isTransient, isTrue);
    expect(const ServerFailure().isTransient, isTrue);
    expect(const ForbiddenFailure().isTransient, isFalse);
  });
}
