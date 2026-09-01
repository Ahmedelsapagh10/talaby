import 'package:flutter_bloc/flutter_bloc.dart';

import '../../store/data/models/store_settings.dart';
import '../../store/data/models/owner.dart';
import '../../store/data/store_repository.dart';
import '../../uploads/data/image_upload_repository.dart';
import 'admin_settings_state.dart';

class AdminSettingsCubit extends Cubit<AdminSettingsState> {
  AdminSettingsCubit(this._repository, this._imageUploads)
    : super(const AdminSettingsState());

  final StoreRepository _repository;
  final ImageUploadRepository _imageUploads;

  Future<void> load() async {
    emit(const AdminSettingsState(status: AdminSettingsStatus.loading));
    try {
      final results = await Future.wait([
        _repository.getOwner(),
        _repository.getSettings(),
      ]);
      emit(
        AdminSettingsState(
          status: AdminSettingsStatus.ready,
          owner: results[0] as Owner?,
          settings: results[1] as StoreSettings? ?? const StoreSettings(),
        ),
      );
    } catch (error) {
      _emitFailure(error);
    }
  }

  Future<void> save(StoreSettings settings) async {
    emit(
      AdminSettingsState(
        status: AdminSettingsStatus.saving,
        owner: state.owner,
        settings: settings,
      ),
    );
    try {
      await _repository.updateSettings(settings);
      emit(
        AdminSettingsState(
          status: AdminSettingsStatus.success,
          owner: state.owner,
          settings: settings,
        ),
      );
    } catch (error) {
      _emitFailure(error, settings: settings);
    }
  }

  Future<void> saveOwner(Owner owner) async {
    emit(
      AdminSettingsState(
        status: AdminSettingsStatus.saving,
        owner: owner,
        settings: state.settings,
      ),
    );
    try {
      await _repository.updateOwnerProfile(owner);
      emit(
        AdminSettingsState(
          status: AdminSettingsStatus.success,
          owner: owner,
          settings: state.settings,
        ),
      );
    } catch (error) {
      _emitFailure(error, owner: owner);
    }
  }

  Future<void> uploadAndSaveLogo() async {
    final owner = state.owner;
    if (owner == null) return;
    emit(
      AdminSettingsState(
        status: AdminSettingsStatus.uploading,
        owner: owner,
        settings: state.settings,
      ),
    );
    try {
      final urls = await _imageUploads.pickAndUpload(
        purpose: ImageUploadPurpose.storeLogo,
        maxFiles: 1,
      );
      if (urls.isEmpty) {
        emit(
          AdminSettingsState(
            status: AdminSettingsStatus.ready,
            owner: owner,
            settings: state.settings,
          ),
        );
        return;
      }
      await saveOwner(owner.copyWith(logoUrl: urls.single));
    } catch (error) {
      _emitFailure(error, owner: owner);
    }
  }

  Future<String?> uploadBannerImage() async {
    emit(
      AdminSettingsState(
        status: AdminSettingsStatus.uploading,
        owner: state.owner,
        settings: state.settings,
      ),
    );
    try {
      final urls = await _imageUploads.pickAndUpload(
        purpose: ImageUploadPurpose.storeBanner,
        maxFiles: 1,
      );
      emit(
        AdminSettingsState(
          status: AdminSettingsStatus.ready,
          owner: state.owner,
          settings: state.settings,
        ),
      );
      return urls.firstOrNull;
    } catch (error) {
      _emitFailure(error);
      return null;
    }
  }

  void _emitFailure(Object error, {Owner? owner, StoreSettings? settings}) {
    emit(
      AdminSettingsState(
        status: AdminSettingsStatus.failure,
        owner: owner ?? state.owner,
        settings: settings ?? state.settings,
        message: error.toString(),
      ),
    );
  }
}
