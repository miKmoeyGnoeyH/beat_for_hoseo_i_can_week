import 'dart:developer';

import 'package:beat/app/route/app_pages.dart';
import 'package:beat/features/authentication/authentication_controller.dart';
import 'package:beat/features/step_count/step_count_controller.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthenticationController authenticationController =
      AuthenticationController.to;

  final TextEditingController idController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool obscurePasswordText = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.designWhite,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 120.w, bottom: 80.w),
                  child: SvgPicture.asset(
                    BEATAssets.svg.logoType1,
                    // width: 121.w,
                    height: 50.w,
                    colorFilter: ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      BEATTextFormField(
                        labelText:
                            LocalizationService.instance.signInHoseoUnivEmailID,
                        controller: idController,
                        maxLength: 8,
                        hintText: LocalizationService
                            .instance
                            .signInHoseoUnivEmailIDHint,
                      ),
                      SizedBox(height: 24.w),
                      BEATTextFormField(
                        labelText: LocalizationService.instance.signInPassword,
                        controller: passwordController,
                        textInputType: TextInputType.emailAddress,
                        hintText:
                            LocalizationService.instance.signInPasswordHint,
                        obscureText: obscurePasswordText,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              obscurePasswordText = !obscurePasswordText;
                            });
                          },
                          child: Icon(
                            obscurePasswordText
                                ? Icons.remove_red_eye_rounded
                                : Icons.remove_red_eye_outlined,
                            color: AppColors.disabledColorLight,
                          ),
                        ),
                      ),
                      SizedBox(height: 36.w),
                      Column(
                        children: [
                          authenticationController.obx(
                            (state) {
                              return BEATTextButton(
                                text: LocalizationService.instance.signInSignIn,
                                onTap: onSignInButtonTap,
                              );
                            },
                            onEmpty: BEATTextButton(
                              text: LocalizationService.instance.signInSignIn,
                              onTap: onSignInButtonTap,
                            ),
                            onError: (_) {
                              return BEATTextButton(
                                text: LocalizationService.instance.signInSignIn,
                                onTap: onSignInButtonTap,
                              );
                            },
                            onLoading: BEATTextButton(
                              text: LocalizationService.instance.signInSignIn,
                              buttonColor: AppColors.common200,
                              textColor: AppColors.common300,
                            ),
                          ),
                          SizedBox(height: 10.w),
                          BEATTextButton(
                            onTap: onSignUpButtonTap,
                            text: LocalizationService.instance.signInSignUp,
                            // textColor: AppColors.designBlack,
                            buttonColor: AppColors.designWhite,
                            textColor: AppColors.designBlack,
                            borderColor: AppColors.common400,
                            highlightColor: AppColors.disabledColorLight,
                            splashColor: AppColors.disabledColorLight,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// [onSignInButtonTap]
  /// 로그인 버튼 클릭 시 호출되는 함수입니다.
  /// ID 필드 또는 비밀번호 필드가 비어있는 경우 다이얼로그를 출력합니다.
  /// 그렇지 않은 경우 서버로 로그인 요청을 전송합니다. 응답 코드가 200이 아닌 경우 로그인 실패 다이얼로그를 출력합니다.
  /// 정상적으로 로그인이 수행된 경우 사용자 객체를 JSON으로 직렬화해 저장하고,
  /// 다음 로그인 시 저장된 사용자 객체를 역직렬화하여 로그인 화면을 건너뛰고 홈 화면으로 이동합니다.
  ///
  /// JWT 토큰 만료 시 처리 로직을 고민해봐야 합니다.
  Future<void> onSignInButtonTap() async {
    if (idController.text.isEmpty || passwordController.text.isEmpty) {
      DialogService.to.addDialogEvent(
        AlertDialogEvent(
          title: LocalizationService.instance.errorEmptyField,
          message: LocalizationService.instance.errorPleaseEnterIDAndPassword,
        ),
      );
      return;
    }

    try {
      await Get.showOverlay(
        asyncFunction: () async {
          await Future.delayed(Duration(milliseconds: 100));
          await authenticationController.signIn(
            idController.text,
            passwordController.text,
          );
          await PrefsService.instance.setUser(
            authenticationController.state!.toJson(),
          );
          // await StepCountController.to.startService();
        },
        loadingWidget: BEATCircularProgressIndicator(),
        opacity: 0.3,
      );
      Get.offAndToNamed(BEATRoute.mainPageView);
    } on BEATException catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      log("SignIn: onSignInButtonTap: BEATException: ${e.toString()}");
      ExceptionService.to.addException(e);
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      log("SignIn: onSignInButtonTap: catch e: ${e.toString()}");
      ExceptionService.to.addException(
        BEATException(
          title: LocalizationService.instance.errorSignInFailed,
          message: LocalizationService.instance.errorUnknown,
        ),
      );
    }
  }

  void onSignUpButtonTap() {
    Get.toNamed(BEATRoute.campus);
  }
}
