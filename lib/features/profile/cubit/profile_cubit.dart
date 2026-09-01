import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/customer_profile.dart';
import '../data/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileState());

  final ProfileRepository _repository;

  Future<void> load(String userId) async {
    emit(const ProfileState(status: ProfileStatus.loading));
    try {
      final profile = await _repository.getProfile(userId);
      emit(ProfileState(status: ProfileStatus.ready, profile: profile));
    } catch (error) {
      emit(
        ProfileState(status: ProfileStatus.failure, message: error.toString()),
      );
    }
  }

  Future<void> save(CustomerProfile profile) async {
    emit(ProfileState(status: ProfileStatus.saving, profile: profile));
    try {
      await _repository.updateProfile(profile);
      emit(ProfileState(status: ProfileStatus.success, profile: profile));
    } catch (error) {
      emit(
        ProfileState(
          status: ProfileStatus.failure,
          profile: profile,
          message: error.toString(),
        ),
      );
    }
  }
}
