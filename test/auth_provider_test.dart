// test/auth_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:inzynier/services/auth_service.dart';
import 'package:inzynier/providers/auth_provider.dart';

// Import the generated mocks file
import 'auth_provider_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  test('login success', () async {
    when(mockAuthService.login(any, any)).thenAnswer((_) async => {
      'id': '1',
      'email': 'test@test.com',
      'name': 'Test User',
      'role': 'client',
      'phone_number': '1234567890',
      'age': '30'
    });

    final authProvider = AuthProvider(authService: mockAuthService);

    await authProvider.login('test@test.com', 'password');

    expect(authProvider.isAuthenticated, true);
    expect(authProvider.user, isNotNull);
    expect(authProvider.user!['name'], 'Test User');
  });
}
