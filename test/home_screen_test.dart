import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:inzynier/screens/home_screen.dart';
import 'package:inzynier/providers/auth_provider.dart';
import 'package:inzynier/services/auth_service.dart';

// Import the generated mocks file
import 'home_screen_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  testWidgets('HomeScreen shows client buttons when authenticated as client', (WidgetTester tester) async {
    // Arrange
    when(mockAuthService.login(any, any)).thenAnswer((_) async => {
      'id': '1',
      'email': 'test@test.com',
      'name': 'Test User',
      'role': 'client',
      'phone_number': '1234567890',
      'age': '30'
    });

    final authProvider = AuthProvider(authService: mockAuthService);

    // Act
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: MaterialApp(home: HomeScreen()),
      ),
    );

    // Authenticate
    await authProvider.login('test@test.com', 'password');

    // Trigger rebuild
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Create Task'), findsOneWidget);
    expect(find.text('View My Tasks'), findsOneWidget);
  });
}
