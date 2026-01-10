import 'package:bloc_test/bloc_test.dart';
import 'package:chefkit/blocs/auth/auth_cubit.dart';
import 'package:chefkit/domain/models/user_model.dart';
import 'package:chefkit/domain/offline_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOffline extends Mock implements OfflineProvider {}

void main() {
  const baseUrl = 'https://test.com';
  late AuthCubit cubit;
  late MockOffline mockOffline;

  AuthCubit createCubit() => AuthCubit(baseUrl: baseUrl, offline: mockOffline);

  setUp(() {
    mockOffline = MockOffline();
    cubit = createCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  group('AuthCubit validations', () {
    test('Initial state should be empty', () {
      expect(cubit.state.loading, false);
      expect(cubit.state.user, null);
      expect(cubit.state.fieldErrors, isEmpty);
    });

    blocTest<AuthCubit, AuthState>(
      'Should show error if name is too short',
      build: createCubit,
      act: (cubit) => cubit.signup('Ab', 'email@test.com', 'pass1234', 'pass1234'),
      expect: () => [
        isA<AuthState>().having((s) => s.loading, 'loading', true),
        isA<AuthState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.fieldErrors['name'], 'error', 'Full name is too short'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'Should show error if email is invalid during signup',
      build: createCubit,
      act: (cubit) => cubit.signup('John Doe', 'bad-email', 'password123', 'password123'),
      expect: () => [
        isA<AuthState>().having((s) => s.loading, 'loading', true),
        isA<AuthState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.fieldErrors['email'], 'error', 'Invalid email'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'Should show error if password is too short during signup',
      build: createCubit,
      act: (cubit) => cubit.signup('John Doe', 'email@test.com', 'short', 'short'),
      expect: () => [
        isA<AuthState>().having((s) => s.loading, 'loading', true),
        isA<AuthState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.fieldErrors['password'], 'error', 'Password must be 8+ chars'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'Should show error if passwords do not match',
      build: createCubit,
      act: (cubit) => cubit.signup('John Doe', 'email@test.com', 'password123', 'wrong_pass'),
      expect: () => [
        isA<AuthState>().having((s) => s.loading, 'loading', true),
        isA<AuthState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.fieldErrors['confirm'], 'error', 'Passwords don’t match'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'Should show error if email format is invalid on login',
      build: createCubit,
      act: (cubit) => cubit.login('bad-email', 'password123'),
      expect: () => [
        isA<AuthState>().having((s) => s.loading, 'loading', true),
        isA<AuthState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.fieldErrors['email'], 'error', 'Invalid email format'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'Should show error if password is too short on login',
      build: createCubit,
      act: (cubit) => cubit.login('email@test.com', '123'),
      expect: () => [
        isA<AuthState>().having((s) => s.loading, 'loading', true),
        isA<AuthState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.fieldErrors['password'], 'error', 'Password too short'),
      ],
    );
  });

  group('AuthCubit helpers', () {
    blocTest<AuthCubit, AuthState>(
      'updateProfile does nothing when user is null',
      build: createCubit,
      act: (cubit) => cubit.updateProfile(
        fullName: 'New',
        email: 'new@test.com',
        phoneNumber: '123',
        bio: 'bio',
      ),
      expect: () => [],
    );

    blocTest<AuthCubit, AuthState>(
      'clearAuthFieldErrors resets fieldErrors and error',
      build: createCubit,
      seed: () => AuthState(
        loading: false,
        fieldErrors: {'email': 'Invalid email'},
        error: 'some error',
      ),
      act: (cubit) => cubit.clearAuthFieldErrors(),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.fieldErrors, 'fieldErrors', isEmpty)
            .having((s) => s.error, 'error', null),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'resetOtpAndSignupState clears flags and pending email',
      build: createCubit,
      seed: () => AuthState(
        needsOtp: true,
        signedUp: true,
        fieldErrors: {'email': 'Invalid'},
        error: 'error',
      ),
      act: (cubit) {
        cubit.pendingEmail = 'pending@test.com';
        cubit.resetOtpAndSignupState();
      },
      expect: () => [
        isA<AuthState>()
            .having((s) => s.needsOtp, 'needsOtp', false)
            .having((s) => s.signedUp, 'signedUp', false)
            .having((s) => s.fieldErrors, 'fieldErrors', isEmpty)
            .having((s) => s.error, 'error', null),
      ],
      verify: (cubit) {
        expect(cubit.pendingEmail, isNull);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'updateProfile replaces user info when user exists',
      build: createCubit,
      seed: () => AuthState(
        user: UserModel(
          fullName: 'Old',
          email: 'old@test.com',
          phoneNumber: '000',
          bio: 'old bio',
        ),
      ),
      act: (cubit) => cubit.updateProfile(
        fullName: 'New Name',
        email: 'new@test.com',
        phoneNumber: '12345',
        bio: 'new bio',
      ),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.user?.fullName, 'fullName', 'New Name')
            .having((s) => s.user?.email, 'email', 'new@test.com')
            .having((s) => s.user?.phoneNumber, 'phone', '12345')
            .having((s) => s.user?.bio, 'bio', 'new bio'),
      ],
    );
  });
}