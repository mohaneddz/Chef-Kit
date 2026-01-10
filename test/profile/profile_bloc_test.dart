import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:chefkit/blocs/profile/profile_bloc.dart';
import 'package:chefkit/blocs/profile/profile_events.dart';
import 'package:chefkit/blocs/profile/profile_state.dart';

import '../helpers/mocks.dart';

void main() {
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
  });

  group('ProfileBloc', () {
    final testProfile = createTestUserProfile(
      id: 'user-123',
      name: 'John Doe',
      email: 'john@example.com',
      recipesCount: 15,
    );

    blocTest<ProfileBloc, ProfileState>(
      'LoadProfile emits loading then loaded state on success',
      build: () {
        when(
          () => mockProfileRepository.fetchProfile('user-123'),
        ).thenAnswer((_) async => testProfile);
        return ProfileBloc(repository: mockProfileRepository);
      },
      act: (bloc) => bloc.add(LoadProfile(userId: 'user-123')),
      expect: () => [
        isA<ProfileState>().having((s) => s.loading, 'loading', true),
        isA<ProfileState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.profile!.name, 'name', 'John Doe'),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'LoadProfile emits error state on failure',
      build: () {
        when(
          () => mockProfileRepository.fetchProfile('user-123'),
        ).thenThrow(Exception('Network error'));
        return ProfileBloc(repository: mockProfileRepository);
      },
      act: (bloc) => bloc.add(LoadProfile(userId: 'user-123')),
      expect: () => [
        isA<ProfileState>().having((s) => s.loading, 'loading', true),
        isA<ProfileState>().having((s) => s.error, 'error', isNotNull),
      ],
    );
  });
}
