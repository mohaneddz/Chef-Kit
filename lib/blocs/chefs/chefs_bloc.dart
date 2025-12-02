import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/chef_repository.dart';
import 'chefs_events.dart';
import 'chefs_state.dart';

class ChefsBloc extends Bloc<ChefsEvent, ChefsState> {
  final ChefRepository repository;
  ChefsBloc({required this.repository}) : super(ChefsState()) {
    on<LoadChefs>(_onLoad);
    on<GoToChefsPage>(_onGoToPage);
  }

  Future<void> _onLoad(LoadChefs event, Emitter<ChefsState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final all = await repository.fetchAllChefs();
      final hot = all.where((c) => c.isOnFire).toList();
      emit(state.copyWith(loading: false, allChefs: all, superHotChefs: hot));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void _onGoToPage(GoToChefsPage event, Emitter<ChefsState> emit) {
    emit(state.copyWith(currentPage: event.page));
  }
}
