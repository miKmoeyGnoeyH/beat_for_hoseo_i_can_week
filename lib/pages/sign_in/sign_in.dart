import 'dart:developer';

import 'package:beat/features/authentication/authentication_controller.dart';
import 'package:beat/shared/index.dart';
import 'package:beat/shared/widgets/beat_assets.dart';
import 'package:beat/shared/widgets/beat_cpi.dart';
import 'package:beat/shared/widgets/beat_text_button.dart';
import 'package:beat/shared/widgets/beat_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class SignIn extends StatelessWidget {
  SignIn({super.key});

  final AuthenticationController authenticationController =
      Get.find<AuthenticationController>();
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                  padding: EdgeInsets.only(top: 140.w, bottom: 48.w),
                  child: SvgPicture.asset(
                    BEATAssets.svg.greenCampusType1,
                    width: 121.w,
                    height: 37.w,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      BEATTextFormField(
                        labelText: LocalizationService.instance.signInHoseoUnivEmailID,
                        textInputType: TextInputType.number,
                        controller: idController,
                        maxLength: 8,
                        hintText:
                            LocalizationService.instance.signInHoseoUnivEmailIDHint,
                      ),
                      SizedBox(height: 24.w),
                      BEATTextFormField(
                        labelText: LocalizationService.instance.signInPassword,
                        controller: passwordController,
                        hintText:
                            LocalizationService.instance.signInPasswordHint,
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
                              textColor: AppColors.gray300,
                              buttonColor: AppColors.gray100,
                            ),
                          ),
                          SizedBox(height: 10.w),
                          BEATTextButton(
                            text: LocalizationService.instance.signInRegister,
                            // textColor: AppColors.designBlack,
                            textColor: AppColors.common500,
                            buttonColor: AppColors.common300,
                            borderColor: AppColors.common100,
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

  Future<void> onSignInButtonTap() async {
    try {
      await Get.showOverlay(
        asyncFunction: () => authenticationController.signIn(idController.text, passwordController.text),
        loadingWidget: BEATCircularProgressIndicator(),
        opacity: 0.3,
      );
    } on BEATException catch (e) {
      log("SignIn: onSignInButtonTap: BEATException: ${e.toString()}");
      Get.find<ExceptionService>().addException(e);
    } catch (e) {
      log("SignIn: onSignInButtonTap: catch e: ${e.toString()}");
      Get.find<ExceptionService>().addException(
        BEATException(title: LocalizationService.instance.errorsUnknownError),
      );
    }
  }
}
