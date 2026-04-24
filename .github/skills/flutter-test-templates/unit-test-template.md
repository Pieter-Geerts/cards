# Unit Test Template

Create in `test/unit/`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cards/models/user.dart';
import 'package:cards/services/user_service.dart';
import 'package:cards/repositories/user_repository.dart';

// Mock Dependencies
class MockUserService extends Mock implements UserService {}

void main() {
  group('UserRepository Unit Tests', () {
    late MockUserService mockUserService;
    late UserRepository userRepository;

    setUp(() {
      mockUserService = MockUserService();
      userRepository = UserRepository(userService: mockUserService);
    });

    group('getUserProfile', () {
      final tUser = User(
        id: '123',
        email: 'john@example.com',
        name: 'John Doe',
        avatar: 'avatar.png',
      );

      test('returns User on successful API call', () async {
        // Arrange
        when(() => mockUserService.fetchProfile(userId: '123'))
            .thenAnswer((_) async => tUser);

        // Act
        final result = await userRepository.getUserProfile(userId: '123');

        // Assert
        expect(result, equals(tUser));
        verify(() => mockUserService.fetchProfile(userId: '123')).called(1);
      });

      test('throws exception on API failure', () async {
        // Arrange
        when(() => mockUserService.fetchProfile(userId: '123'))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => userRepository.getUserProfile(userId: '123'),
          throwsException,
        );
      });

      test('returns cached user if available', () async {
        // Arrange - First call
        when(() => mockUserService.fetchProfile(userId: '123'))
            .thenAnswer((_) async => tUser);

        await userRepository.getUserProfile(userId: '123');

        // Act - Second call (should use cache)
        reset(mockUserService);
        final result = await userRepository.getUserProfile(userId: '123');

        // Assert - Service not called again
        expect(result, equals(tUser));
        verifyNever(() => mockUserService.fetchProfile(userId: '123'));
      });
    });

    group('updateUserProfile', () {
      test('updates user successfully', () async {
        // Arrange
        const updates = {'name': 'Jane Doe'};
        final updatedUser = User(
          id: '123',
          email: 'john@example.com',
          name: 'Jane Doe',
          avatar: null,
        );

        when(() => mockUserService.updateProfile(
          userId: '123',
          updates: updates,
        )).thenAnswer((_) async => updatedUser);

        // Act
        final result = await userRepository.updateUserProfile(
          userId: '123',
          updates: updates,
        );

        // Assert
        expect(result.name, equals('Jane Doe'));
        verify(
          () => mockUserService.updateProfile(
            userId: '123',
            updates: updates,
          ),
        ).called(1);
      });

      test('validates email format before update', () async {
        // Act & Assert
        expect(
          () => userRepository.updateUserProfile(
            userId: '123',
            updates: {'email': 'invalid-email'},
          ),
          throwsArgumentError,
        );

        // Verify service was never called
        verifyNever(
          () => mockUserService.updateProfile(
            userId: any(named: 'userId'),
            updates: any(named: 'updates'),
          ),
        );
      });
    });

    group('deleteUser', () {
      test('deletes user and clears cache', () async {
        // Arrange
        when(() => mockUserService.deleteProfile(userId: '123'))
            .thenAnswer((_) async => true);

        // Act
        await userRepository.deleteUser(userId: '123');

        // Assert
        verify(() => mockUserService.deleteProfile(userId: '123')).called(1);

        // Verify cache is cleared
        expect(
          () => userRepository.getUserProfile(userId: '123'),
          throwsException, // Should not return cached value
        );
      });
    });
  });
}
```

---

## Unit Testing Best Practices

✅ **AAA Pattern**: Arrange → Act → Assert for clarity  
✅ **Mock External Dependencies**: Isolate the code under test  
✅ **One Assert per Test**: Keep tests focused (or use expect multiple times for related assertions)  
✅ **Meaningful Test Names**: Describe the scenario and expected outcome  
✅ **Test Edge Cases**: Null inputs, empty lists, exceptions  
✅ **Verify Method Calls**: Use Mockito's `verify()` to ensure correct interactions  
✅ **Test Caching & State**: If repository has cache, verify it works correctly  

---

## Coverage Target: 80%+

```bash
flutter test --coverage
open coverage/lcov.html  # View coverage report
```
