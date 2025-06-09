import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:gym_management_flutter/features/auth/data/services/auth_service.dart';
import 'package:dio/dio.dart';

@GenerateMocks([Dio])
void main() {
  late AuthService authService;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    authService = AuthService(mockDio);
  });

  group('AuthService Tests', () {
    test('login should return user data on successful login', () async {
      // Arrange
      final loginData = {'email': 'test@test.com', 'password': 'password'};
      final responseData = {
        'id': 1,
        'email': 'test@test.com',
        'name': 'Test User',
        'role': 'member'
      };

      when(mockDio.post('/auth/login', data: loginData))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: '/auth/login'),
              ));

      // Act
      final result = await authService.login(loginData);

      // Assert
      expect(result, isNotNull);
      expect(result['email'], equals('test@test.com'));
      expect(result['role'], equals('member'));
    });

    test('login should throw exception on failed login', () async {
      // Arrange
      final loginData = {'email': 'test@test.com', 'password': 'wrong'};

      when(mockDio.post('/auth/login', data: loginData))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/auth/login'),
        ),
      ));

      // Act & Assert
      expect(() => authService.login(loginData), throwsException);
    });
  });
} 