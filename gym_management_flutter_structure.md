# Gym Management System - Flutter Implementation

## Project Structure
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── api_constants.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       └── error_interceptor.dart
│   ├── utils/
│   │   ├── input_validator.dart
│   │   └── date_formatter.dart
│   └── theme/
│       ├── app_theme.dart
│       └── app_colors.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_data_source.dart
│   │   │   │   └── auth_local_data_source.dart
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   └── auth_response_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       └── register_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── auth_provider.dart
│   │       │   └── auth_state.dart
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   ├── register_screen.dart
│   │       │   └── splash_screen.dart
│   │       └── widgets/
│   │           ├── login_form.dart
│   │           └── register_form.dart
│   ├── workout/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── workout_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── workout_model.dart
│   │   │   └── repositories/
│   │   │       └── workout_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── workout.dart
│   │   │   ├── repositories/
│   │   │   │   └── workout_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_workouts_usecase.dart
│   │   │       └── create_workout_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── workout_provider.dart
│   │       │   └── workout_state.dart
│   │       ├── screens/
│   │       │   ├── workout_list_screen.dart
│   │       │   └── workout_detail_screen.dart
│   │       └── widgets/
│   │           ├── workout_card.dart
│   │           └── workout_form.dart
│   └── event/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── event_remote_data_source.dart
│       │   ├── models/
│       │   │   └── event_model.dart
│       │   └── repositories/
│       │       └── event_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── event.dart
│       │   ├── repositories/
│       │   │   └── event_repository.dart
│       │   └── usecases/
│       │       ├── get_events_usecase.dart
│       │       └── create_event_usecase.dart
│       └── presentation/
│           ├── providers/
│           │   ├── event_provider.dart
│           │   └── event_state.dart
│           ├── screens/
│           │   ├── event_list_screen.dart
│           │   └── event_detail_screen.dart
│           └── widgets/
│               ├── event_card.dart
│               └── event_form.dart
└── shared/
    ├── widgets/
    │   ├── custom_button.dart
    │   ├── custom_text_field.dart
    │   └── loading_indicator.dart
    └── navigation/
        ├── app_router.dart
        └── route_generator.dart
```

## Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # Network
  dio: ^5.4.0
  pretty_dio_logger: ^1.3.1
  
  # Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # Utils
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  intl: ^0.18.1
  
  # UI
  cached_network_image: ^3.3.1
  flutter_svg: ^2.0.9
  google_fonts: ^6.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  # Code Generation
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.9
  
  # Testing
  mockito: ^5.4.4
  integration_test:
    sdk: flutter
  golden_toolkit: ^0.15.0
```

## Testing Structure
```
test/
├── unit/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── domain/
│   │   │   │   └── usecases/
│   │   │   │       ├── login_usecase_test.dart
│   │   │   │       └── register_usecase_test.dart
│   │   │   └── data/
│   │   │       └── repositories/
│   │   │           └── auth_repository_impl_test.dart
│   │   ├── workout/
│   │   └── event/
│   └── core/
│       └── utils/
│           └── input_validator_test.dart
├── widget/
│   └── features/
│       ├── auth/
│       │   ├── screens/
│       │   │   ├── login_screen_test.dart
│       │   │   └── register_screen_test.dart
│       │   └── widgets/
│       │       ├── login_form_test.dart
│       │       └── register_form_test.dart
│       ├── workout/
│       └── event/
└── integration/
    ├── app_test.dart
    └── features/
        ├── auth_flow_test.dart
        ├── workout_flow_test.dart
        └── event_flow_test.dart
```

## Key Implementation Details

### 1. State Management with Riverpod
```dart
// Example of a provider using Riverpod
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    return const AuthState.initial();
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      final result = await ref.read(loginUseCaseProvider).call(
        LoginParams(email: email, password: password),
      );
      state = AuthState.authenticated(result);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}
```

### 2. API Integration with Dio
```dart
// Example of Dio client setup
class DioClient {
  final Dio _dio;
  
  DioClient() : _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  )) {
    _dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
      PrettyDioLogger(),
    ]);
  }
  
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      throw ServerException();
    }
  }
}
```

### 3. Repository Pattern
```dart
// Example of repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
```

### 4. Use Cases
```dart
// Example of a use case
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}
```

### 5. Testing Examples

#### Unit Test
```dart
void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  test('should return user when login is successful', () async {
    // arrange
    when(mockRepository.login(any, any))
        .thenAnswer((_) async => Right(tUser));
    
    // act
    final result = await useCase(LoginParams(
      email: 'test@example.com',
      password: 'password123',
    ));
    
    // assert
    expect(result, Right(tUser));
    verify(mockRepository.login('test@example.com', 'password123'));
    verifyNoMoreInteractions(mockRepository);
  });
}
```

#### Widget Test
```dart
void main() {
  testWidgets('Login form validation works correctly', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Test empty form submission
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Email is required'), findsOneWidget);

    // Test invalid email
    await tester.enterText(
      find.byType(TextFormField).first,
      'invalid-email',
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Please enter a valid email'), findsOneWidget);
  });
}
```

#### Integration Test
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow', () {
    testWidgets('Complete login flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify splash screen
      expect(find.byType(SplashScreen), findsOneWidget);
      await tester.pumpAndSettle();

      // Navigate to login
      expect(find.byType(LoginScreen), findsOneWidget);

      // Enter credentials
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );

      // Submit
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify navigation to home
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
```

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter pub run build_runner build` to generate code
4. Run `flutter test` to run all tests
5. Run `flutter run` to start the app

## Additional Notes

1. The project follows Clean Architecture principles with clear separation of concerns
2. All features are organized in a feature-first structure
3. Each feature follows the same pattern:
   - data (repositories, models, datasources)
   - domain (entities, repositories, usecases)
   - presentation (providers, screens, widgets)
4. Testing is comprehensive with unit, widget, and integration tests
5. State management is handled by Riverpod
6. API calls are made using Dio with proper error handling
7. The project uses code generation for models and providers
8. Secure storage is used for sensitive data
9. The UI is responsive and follows Material Design guidelines 