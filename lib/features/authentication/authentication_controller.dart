import 'dart:developer';

import 'package:beat/entities/authentication/authentication_model.dart';
import 'package:beat/features/authentication/authentication_repository.dart';
import 'package:get/get.dart';

class AuthenticationController extends GetxController
    with StateMixin<AuthenticationModel> {
  AuthenticationController() {
    change(null, status: RxStatus.empty());
  }

  Future<void> signIn(String id, String nickname) async {
    change(null, status: RxStatus.loading());

    // await Future.delayed(Duration(seconds: 5));
    // change(null, status: RxStatus.success());

    try {
      final AuthenticationModel authenticationModel =
          await authenticationRepository.signIn(id: id, nickname: nickname);
      change(authenticationModel, status: RxStatus.success());
    } catch (e) {
      log("AuthenticationController : signIn() : ${e.toString()}");
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  final AuthenticationRepository authenticationRepository =
      AuthenticationRepository();
}
