import 'dart:developer';

import 'package:beat/entities/authentication/user_model.dart';
import 'package:beat/features/authentication/authentication_repository.dart';
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
      final UserModel authenticationModel =
          await authenticationRepository.signIn(id: id, password: password);
      change(authenticationModel, status: RxStatus.success());
    } catch (e) {
      log("AuthenticationController : signIn() : ${e.toString()}");
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  void signInFromJson(Map<String, dynamic> json) {
    change(UserModel.fromJson(json), status: RxStatus.success());
  }

  final AuthenticationRepository authenticationRepository =
      AuthenticationRepository();
}
