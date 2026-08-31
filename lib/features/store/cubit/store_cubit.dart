import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/owner.dart';
import '../data/models/store_settings.dart';
import '../data/store_repository.dart';
import 'store_state.dart';

class StoreCubit extends Cubit<StoreState> {
  StoreCubit(this._repository) : super(const StoreState());

  final StoreRepository _repository;
  StreamSubscription<Owner?>? _ownerSubscription;
  StreamSubscription<StoreSettings?>? _settingsSubscription;

  void watch() {
    emit(const StoreState(status: StoreStatus.loading));
    _ownerSubscription = _repository.watchOwner().listen(
      (owner) => emit(
        StoreState(
          status: owner == null ? StoreStatus.empty : StoreStatus.success,
          owner: owner,
          settings: state.settings,
        ),
      ),
      onError: _emitFailure,
    );
    _settingsSubscription = _repository.watchSettings().listen(
      (settings) => emit(
        StoreState(
          status: state.owner == null ? StoreStatus.empty : StoreStatus.success,
          owner: state.owner,
          settings: settings,
        ),
      ),
      onError: _emitFailure,
    );
  }

  void _emitFailure(Object error) {
    emit(
      StoreState(
        status: StoreStatus.failure,
        owner: state.owner,
        settings: state.settings,
        message: error.toString(),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _ownerSubscription?.cancel();
    await _settingsSubscription?.cancel();
    return super.close();
  }
}
