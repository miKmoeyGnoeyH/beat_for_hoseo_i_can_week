import 'dart:developer';

import 'package:beat/entities/profile/index.dart';
import 'package:get/get.dart';

import 'profile_repository.dart';

class ProfileController extends GetxController with StateMixin<ProfileModel> {
  ProfileController() {
    change(null, status: RxStatus.empty());
  }

  static ProfileController get to => Get.find();

  Future<void> fetchData(String authorization) async {
    change(state, status: RxStatus.loading());

    try {
      final ProfileModel profileModel =
      await profileRepository.fetchData(authorization);
      change(profileModel, status: RxStatus.success());
    } catch (e) {
      log("ProfileController : fetchData() : ${e.toString()}");
      _didInitialFetch = false;
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  Future<void> fetchDataOnce(String authorization) async {
    if (_didInitialFetch) return;
    _didInitialFetch = true;
    await fetchData(authorization);
  }

  final ProfileRepository profileRepository =
  ProfileRepository();
  bool _didInitialFetch = false;
}