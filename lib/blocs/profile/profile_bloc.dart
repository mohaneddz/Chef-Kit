import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_events.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;
  ProfileBloc({required this.repository}) : super(ProfileState()) {
    on<LoadProfile>(_onLoad);
    on<IncrementProfileRecipes>(_onIncrementRecipes);
    on<UpdatePersonalInfo>(_onUpdatePersonalInfo);
  }

  Future<void> _onLoad(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final profile = await repository.fetchProfile(event.userId);
      emit(state.copyWith(loading: false, profile: profile));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onIncrementRecipes(IncrementProfileRecipes event, Emitter<ProfileState> emit) async {
    try {
      final updated = await repository.incrementRecipes();
      emit(state.copyWith(profile: updated));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdatePersonalInfo(UpdatePersonalInfo event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(saving: true, error: null));
    try {
      final updated = await repository.updatePersonalInfo(
        userId: event.userId,
        fullName: event.fullName,
        bio: event.bio,
        story: event.story,
        specialties: event.specialties,
      );
      emit(state.copyWith(saving: false, profile: updated, error: null));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }
}
