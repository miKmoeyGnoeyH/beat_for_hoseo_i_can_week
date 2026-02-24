import 'dart:developer';

import 'package:beat/entities/authentication/user_model.dart';
import 'package:beat/features/authentication/authentication_repository.dart';
import 'package:beat/features/point/index.dart';
import 'package:beat/features/profile/index.dart';
import 'package:beat/features/quest/index.dart';
import 'package:beat/shared/index.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class AuthenticationController extends GetxController
    with StateMixin<UserModel> {
  AuthenticationController() {
    change(null, status: RxStatus.empty());
  }

  static AuthenticationController get to => Get.find();

  Future<void> signIn(String id, String password) async {
    change(null, status: RxStatus.loading());

    /// 디버그용 딜레이 코드입니다.
    /// `Future.delayed` 뒤에 원하는 동작(성공, 예외 throw)을 추가해주세요.
    // await Future.delayed(Duration(seconds: 5));
    // change(null, status: RxStatus.success());

    try {
      final UserModel authenticationModel = await authenticationRepository
          .signIn(id: id, password: password);

      /// signIn()은 성공 시에만 UserModel을 반환하고, 그 외는 모두 Exception을 throw하기 때문에
      /// UserModel을 반환받았다는 것은 API 호출이 성공했음을 의미.
      /// 바로 FCMToken 등록으로 넘어감
      final String authorization = authenticationModel.authorization;
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        throw Exception();
      } else {
        if (!await authenticationRepository.registerFCMToken(
          authorization,
          fcmToken,
        )) {
          throw Exception();
        }
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        final String? authorizationAtTime = state?.authorization;
        if (authorizationAtTime == null) return;
        authenticationRepository.registerFCMToken(authorizationAtTime, token);
      });

      change(authenticationModel, status: RxStatus.success());
    } catch (e) {
      log("AuthenticationController : signIn() : ${e.toString()}");
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  Future<void> reissueToken() async {
    try {
      final String newAuthorization = await authenticationRepository
          .reissueToken(state!.refreshToken);

      final UserModel newUser = UserModel.reissueToken(
        state!,
        newAuthorization,
      );

      change(newUser, status: RxStatus.success());
      await PrefsService.instance.setUser(newUser.toJson());
    } catch (e) {
      log("AuthenticationController : reissueToken() : ${e.toString()}");
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  void signInFromJson(Map<String, dynamic> json) {
    change(UserModel.fromJson(json), status: RxStatus.success());
  }

  Future<void> signOut() async {
    await PrefsService.instance.clearUser();
    await QuestListController.to.clearQuestList();
    await QuestDetailController.to.clearQuestDetail();
    await PointController.to.clearPointBalance();
    await ProfileController.to.clearData();
    change(null, status: RxStatus.empty());
  }

  final AuthenticationRepository authenticationRepository =
      AuthenticationRepository();
}
